import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pro_meca/core/models/brand.dart';
import 'package:pro_meca/core/models/modele.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/vehicle.dart';

class ApiDioService {
  String get apiUrl {
    return dotenv.env['API_URL'] ?? '';
  }

  final Dio _dio;
  ApiDioService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['API_URL'] ?? '',
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );
  Future<Map<String, String>> getAuthHeaders() async {
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
      await logoutUser();
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
          await saveAuthData(
            accessToken: responseData['accessToken'],
            refreshToken: responseData['refreshToken'],
            refreshExpiresAt: responseData['refreshExpiresAt'],
            expiresAt: responseData['expiresAt'],
            user: User.fromJson(responseData['user']),
            rememberMe: prefs.getBool('remember_me') ?? false,
          );
          return true;
        } else {
          await logoutUser();
          throw Exception('Échec du rafraîchissement du token');
        }
      } catch (e) {
        await logoutUser();
        throw Exception('Erreur lors du rafraîchissement: ${e.toString()}');
      }
    }
    return false;
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('user');
    await prefs.remove('isAdmin');
  }

  Future<Response> authenticatedRequest(
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
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        // Vérification directe si response.data est une chaîne
        if (response.data is String) {
          return response.data.toLowerCase().contains('pong');
        }
      }
    } on DioException catch (dioError) {
      // Gestion des erreurs spécifiques à Dio
      print('Erreur de connexion : ${dioError.message}');
    } catch (e) {
      print('Erreur inattendue : $e');
    }
    return false;
  }

  Future<void> saveAuthData({
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
      return User.fromUserJson(json.decode(userData));
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

  Future<String?> createVehicle(FormData formData) async {
    final response = await authenticatedRequest(
      () async => await _dio.post(
        '$apiUrl/vehicles/create',
        data: formData,
        options: Options(headers: await getAuthHeaders()),
      ),
    );

    print('Response Status Code: ${formData.fields}');
    if (response.statusCode == 201) {
      final responseData = response.data;
      return Vehicle.fromJson(responseData['data']).id;
    } else {
      final errorData = response.data;
      print(formData.fields.toString());
      throw Exception('Failed to create vehicle: ${errorData['message']}');
    }
  }

  Future<List<Brand>> getAllBrands() async {
    final response = await authenticatedRequest(
      () async => await _dio.get(
        '/brands',
        options: Options(headers: await getAuthHeaders()),
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
    final response = await authenticatedRequest(
      () async => await _dio.get(
        '/brands/$brandId',
        options: Options(headers: await getAuthHeaders()),
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
