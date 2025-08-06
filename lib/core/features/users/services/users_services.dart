
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/dio_api_services.dart';
import '../../../models/role.dart';
import '../../../models/user.dart';

class UserService{
  final Dio _dio;
  UserService()
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiDioService().apiUrl,
      contentType: 'application/json',
      responseType: ResponseType.json,
    ),
  );


  Future<User> updateUserProfile(
      String userId,
      Map<String, dynamic> data,
      bool isAdmin
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      throw Exception('Aucun token d\'accès trouvé.');
    }

    try {
      Response response;
      if(isAdmin){
         response = await ApiDioService().authenticatedRequest(
              () => _dio.put(
            '/auth/$userId',
            data: json.encode(data),
            options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          ),
        );
      }else{
         response = await ApiDioService().authenticatedRequest(
              () => _dio.patch(
            '/auth/me',
            data: json.encode(data),
            options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          ),
        );
      }


      if (response.statusCode == 200 && isAdmin) {
        final updatedUser = User.fromUserJson(response.data['data']);
        final currentUser = await ApiDioService().getSavedUser();
        if (currentUser != null && currentUser.id == updatedUser.id) {
          await ApiDioService().saveAuthData(
            accessToken: accessToken,
            refreshToken: prefs.getString('refreshToken') ?? '',
            refreshExpiresAt: prefs.getInt('refreshExpiresAt') ?? 0,
            expiresAt: prefs.getInt('expiresAt') ?? 0,
            user: updatedUser,
            rememberMe: prefs.getBool('remember_me') ?? false,
          );
        }
        return updatedUser;
      }else if(response.statusCode ==  200 && isAdmin == false){
        final updatedUser = User.fromUserUpdateJson(response.data['data']);
        return updatedUser;
      } else {
        throw Exception('Échec de la mise à jour du profil (code ${response.statusCode})');
      }
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception('Délai de connexion dépassé.');
        case DioExceptionType.sendTimeout:
          throw Exception('Délai d’envoi dépassé.');
        case DioExceptionType.receiveTimeout:
          throw Exception('Délai de réponse dépassé.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          final message = e.response?.data?['message'] ?? 'Erreur côté serveur.';
          if (statusCode == 400) {
            throw Exception('Requête invalide : $message');
          } else if (statusCode == 401) {
            throw Exception('Non autorisé. Veuillez vous reconnecter.');
          } else if (statusCode == 403) {
            throw Exception('Accès interdit.');
          } else if (statusCode == 404) {
            throw Exception('Utilisateur non trouvé.');
          } else if (statusCode! >= 500) {
            throw Exception('Erreur serveur ($statusCode) : $message');
          } else {
            throw Exception('Erreur inconnue ($statusCode) : $message');
          }
        case DioExceptionType.cancel:
          throw Exception('Requête annulée.');
        case DioExceptionType.unknown:
        default:
          throw Exception('Erreur réseau ou inconnue. Vérifiez votre connexion.');
      }
    } catch (e) {
      throw Exception('Erreur inattendue : $e');
    }
  }

  Future<User?> uploadUserProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'logo': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_$userId.jpg',
        ),
      });

      final response = await ApiDioService().authenticatedRequest(
          () async => await _dio.put(
            '/auth/$userId',
            data: formData,
            options: Options(
              headers: await ApiDioService().getAuthHeaders(),
          )
          )
      );
      if (response.statusCode == 200) {
        final accessToken = (await SharedPreferences.getInstance()).getString(
          'accessToken',
        );
        final updatedUser = User.fromUserJson(response.data['data']);
        final currentUser = await ApiDioService().getSavedUser();
        if (currentUser != null && currentUser.id == updatedUser.id) {
          await ApiDioService().saveAuthData(
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
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      print("On essaie de charger les users");
      final response = await ApiDioService().authenticatedRequest(
            () async => await _dio.get(
          '/auth/users',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => User.fromUserJson(json)).toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.sendTimeout ||
          dioError.type == DioExceptionType.receiveTimeout) {
        throw Exception('La requête a expiré. Vérifie ta connexion internet.');
      } else if (dioError.type == DioExceptionType.badResponse) {
        final statusCode = dioError.response?.statusCode ?? 0;
        final message = dioError.response?.data['message'] ?? 'Erreur inconnue';
        throw Exception('Erreur serveur [$statusCode] : $message');
      } else if (dioError.type == DioExceptionType.connectionError) {
        throw Exception('Impossible de se connecter au serveur.');
      } else {
        throw Exception('Erreur Dio : ${dioError.message}');
      }
    } catch (e) {
      // Pour toutes les autres erreurs non Dio
      throw Exception('Une erreur inattendue est survenue : $e');
    }
  }

  Future<List<Role>> fetchRoles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Token d\'accès manquant.');
      }

      final response = await ApiDioService().authenticatedRequest(
            () => _dio.get(
          '/auth/roles',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is List) {
          print(data);
          return data.map((json) => Role.fromRoleJson(json)).toList();
        } else {
          throw Exception('Format de données inattendu.');
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Erreur réseau');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<User> createUser(FormData formData) async {
    try {
      final accessToken = (await SharedPreferences.getInstance()).getString('accessToken') ?? '';
      print(formData.fields);
      final response = await ApiDioService().authenticatedRequest(
            () => _dio.post(
          '/auth/create',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'multipart/form-data',
            },
          ),
        ),
      );

      if (response.statusCode == 201) {
        return User.fromUserJson(response.data['data']);
      } else {
        final errorMsg = response.data['message'] ?? 'Erreur inconnue';
        throw Exception('${response.statusCode} - $errorMsg');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response!.data['message'] ?? e.message;
        throw Exception('${e.response!.statusCode} - $errorMsg');
      }
      _handleDioError(e);
      throw Exception('Erreur réseau: ${e.toString()}');
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final errorMsg = e.response?.data['message'] ?? 'Erreur inconnue';
      return Exception('${e.response?.statusCode} - $errorMsg');
    }
    return Exception(e.message ?? 'Erreur réseau');
  }
}