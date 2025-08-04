
import 'package:dio/dio.dart';

import '../../../../services/dio_api_services.dart';
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

}