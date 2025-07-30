import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pro_meca/core/models/dataLogin.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  final Dio _dio;
  AuthServices()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiDioService().apiUrl,
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );

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
}
