import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pro_meca/core/models/brand.dart';
import 'package:pro_meca/core/models/dataLogin.dart';
import 'package:pro_meca/core/models/modele.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/client.dart';
import '../../../core/models/vehicle.dart';

class ApiDioService {
  static const String _baseUrl = 'https://promeca.api.blasco.top';
  final Dio _dio;
  ApiDioService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    return {'Authorization': 'Bearer $accessToken'};
  }

  Future<bool> _checkAndRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = prefs.getInt('expiresAt');
    final refreshExpiresAt = prefs.getInt('refreshExpiresAt');
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (refreshExpiresAt == null || currentTime >= refreshExpiresAt) {
      await _logoutUser();
      throw Exception('Session expirée, veuillez vous reconnecter');
    }
    if (expiresAt == null || currentTime >= expiresAt) {
      try {
        final refreshToken = prefs.getString('refreshToken');
        final response = await _dio.post(
          '/auth/refresh',
          data: json.encode({'refreshToken': refreshToken}),
        );
        if (response.statusCode == 200) {
          final responseData = response.data;
          await _saveAuthData(
            accessToken: responseData['accessToken'],
            refreshToken: responseData['refreshToken'],
            refreshExpiresAt: responseData['refreshExpiresAt'],
            expiresAt: responseData['expiresAt'],
            user: User.fromJson(responseData['user']),
            rememberMe: prefs.getBool('remember_me') ?? false,
          );
          return true;
        } else {
          await _logoutUser();
          throw Exception('Échec du rafraîchissement du token');
        }
      } catch (e) {
        await _logoutUser();
        throw Exception('Erreur lors du rafraîchissement: ${e.toString()}');
      }
    }
    return false;
  }

  Future<void> _logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Response> _authenticatedRequest(
    Future<Response> Function() requestFn,
  ) async {
    await _checkAndRefreshToken();
    final response = await requestFn();

    if (response.statusCode == 401) {
      await _checkAndRefreshToken();
      return await requestFn();
    }
    return response;
  }

  Future<bool> testConnection() async {
    try {
      final response = await _dio
          .get('/ping')
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 &&
          response.data.toString().toLowerCase().contains('pong');
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> authenticateUser({
    required String identifier,
    required String password,
    required String? mail,
    bool rememberMe = false,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: json.encode({
        'phone': identifier,
        'mail': mail,
        'password': password,
        'rememberMe': rememberMe,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = response.data;
      final data = Data.fromJson(responseData['data']);
      await _saveAuthData(
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        refreshExpiresAt: data.refreshExpiresAt,
        expiresAt: data.expiresAt,
        user: data.user,
        rememberMe: rememberMe,
      );
      return responseData;
    } else {
      throw Exception('Échec de l\'authentification : ${response.data}');
    }
  }

  Future<void> _saveAuthData({
    required String accessToken,
    required String refreshToken,
    required int refreshExpiresAt,
    required int expiresAt,
    required User user,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setInt("refreshExpiresAt", refreshExpiresAt);
    await prefs.setInt("expiresAt", expiresAt);
    await prefs.setString('user_data', json.encode(user));
    await prefs.setBool('remember_me', rememberMe);
    await prefs.setString("companyId", user.role.companyId);
    if (!rememberMe) {
      await prefs.setBool('session_only', true);
    }
  }

  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<User> getUserProfile(String userId) async {
    final accessToken = (await SharedPreferences.getInstance()).getString(
      'accessToken',
    );
    final response = await _dio.get(
      '/users/$userId',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<User> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final accessToken = (await SharedPreferences.getInstance()).getString(
      'accessToken',
    );
    final response = await _dio.put(
      '/users/$userId',
      data: json.encode(data),
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      final updatedUser = User.fromJson(response.data);
      final currentUser = await getSavedUser();
      if (currentUser != null && currentUser.id == updatedUser.id) {
        await _saveAuthData(
          accessToken: accessToken!,
          refreshToken: (await SharedPreferences.getInstance()).getString(
            'refreshToken',
          )!,
          refreshExpiresAt: (await SharedPreferences.getInstance()).getInt(
            'refreshExpiresAt',
          )!,
          expiresAt: (await SharedPreferences.getInstance()).getInt(
            'expiresAt',
          )!,
          user: updatedUser,
          rememberMe:
              (await SharedPreferences.getInstance()).getBool('remember_me') ??
              false,
        );
      }
      return updatedUser;
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<String> createClient({
    required String firstName,
    required String lastName,
    required String phone,
    String? companyId,
    String? email,
    String? address,
    String? city,
    String? logo,
    String? userId,
    String? clientCompany,
  }) async {
    final _companyId = (await SharedPreferences.getInstance()).getString(
      'companyId',
    );
    final response = await _authenticatedRequest(
      () async => await _dio.post(
        '/clients/create',
        data: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'companyId': _companyId,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
          if (city != null) 'city': city,
          if (logo != null) 'logo': logo,
          if (userId != null) 'userId': userId,
          if (clientCompany != null) 'clientCompany': clientCompany,
        }),
        options: Options(headers: await _getAuthHeaders()),
      ),
    );
    if (response.statusCode == 201) {
      final responseData = response.data;
      return Client.fromJson(responseData['data']).id;
    } else {
      final errorData = response.data;
      throw Exception(
        'Failed to create client: ${errorData['message'] ?? 'Unknown error'}',
      );
    }
  }

  Future<String?> createVehicle(FormData formData) async {
    final response = await _authenticatedRequest(
      () async => await _dio.post(
        '$_baseUrl/vehicles/create',
        data: formData,
        options: Options(headers: await _getAuthHeaders()),
      ),
    );

    print('Response Status Code: ${formData.fields}');
    if (response.statusCode == 201) {
      final responseData = response.data;
      return Vehicle.fromJson(responseData['data']).id;
    } else {
      final errorData = response.data;
      print(formData.fields.toString());
      throw Exception(
        'Failed to create vehicle: ${errorData['message']}',
      );
    }
  }

  Future<List<Brand>> getAllBrands() async {
    final response = await _authenticatedRequest(
      () async => await _dio.get(
        '/brands',
        options: Options(headers: await _getAuthHeaders()),
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> brandsJson = response.data;
      return brandsJson.map((json) => Brand.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  Future<List<Modele>?> getModelsByBrand(String brandId) async {
    final response = await _authenticatedRequest(
      () async => await _dio.get(
        '/brands/$brandId',
        options: Options(headers: await _getAuthHeaders()),
      ),
    );
    if (response.statusCode == 200) {
      final dynamic responseData = response.data;
      if (responseData is List) {
        return responseData.map((json) => Modele.fromJson(json)).toList();
      } else if (responseData is Map<String, dynamic>) {
        final brand = Brand.fromJson(responseData);
        return brand.modeles;
      } else {
        throw FormatException('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load models');
    }
  }
}
