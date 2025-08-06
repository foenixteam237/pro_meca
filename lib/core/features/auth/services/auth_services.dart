import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
          sendTimeout: const Duration(seconds: 10),
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
        'email': mail,
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
    await prefs.setBool("isAdmin", user.isCompanyAdmin);
    if (!rememberMe) {
      await prefs.setBool('session_only', true);
    }
  }

  Future<void> requestPasswordReset({
    String? email,
    String? phone,
    String? adminPhone,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (email != null) {
        data['email'] = email;
      } else if (phone != null && adminPhone != null) {
        data['phone'] = phone;
        data['adminPhone'] = adminPhone;
      } else {
        throw Exception('Either email or phones must be provided');
      }
      final response = await _dio.post('/auth/forgot', data: data);

      if (response.statusCode != 200) {
        throw Exception('Failed to send reset request');
      }
    } catch (e) {
      throw Exception('Password reset request failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> verifyResetCode({
    required String code,
    String? email,
    String? phone,
    String? adminPhone,
  }) async {
    try {
      final Map<String, dynamic> data = {'code': code};

      if (adminPhone != null && phone != null) {
        data['phone'] = phone;
        data['adminPhone'] = adminPhone;
      } else if (email != null) {
        data['email'] = email;
      } else {
        throw (Exception(
          "At least an email or both user phone and admin phone must be provided",
        ));
      }
      final response = await _dio.post('/auth/verify-code', data: data);

      if (response.statusCode != 200) {
        throw Exception('Verification failed');
      }

      return response.data;
    } catch (e) {
      throw Exception('Verification failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword({
    required String code,
    required String id,
    required String newPassword,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'code': code,
        'newPassword': newPassword,
        'id': id,
      };

      final response = await _dio.post('/auth/reset-pass', data: data);

      if (response.statusCode != 200) {
        throw Exception('Reset password failed');
      }
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
}
