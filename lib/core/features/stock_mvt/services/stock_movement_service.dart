import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pro_meca/core/models/stock_movement.dart';
import '../../../../services/dio_api_services.dart';

class StockMovementService {
  final Dio _dio;

  StockMovementService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiDioService().apiUrl,
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );

  Future<StockMovementResponse> getMovements({
    int skip = 0,
    int take = 10,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/stock-movements',
          queryParameters: {'skip': skip, 'take': take, ...?filters},
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (ApiDioService.isSuccess(response)) {
        return StockMovementResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Erreur lors du chargement des mouvements de stock: ${response.data.toString()}',
        );
      }
    } on DioException catch (dioError) {
      throw _handleDioError(
        dioError,
        'Erreur lors du chargement des mouvements de stock',
      );
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors du chargement des mouvements de stock: $e',
      );
    }
  }

  // Future<Map<String, dynamic>> getPieces({
  //   int skip = 0,
  //   int take = 10,
  //   String? search,
  // }) async {
  //   if (kDebugMode) {
  //     print("skip=$skip , take=$take");
  //   }

  //   try {
  //     final Map<String, dynamic> queryParams = {'skip': skip, 'take': take};

  //     // Correction du paramètre de recherche
  //     if (search != null && search.isNotEmpty) {
  //       queryParams['search'] = search;
  //     }

  //     final response = await ApiDioService().authenticatedRequest(
  //       () async => await _dio.get(
  //         'stock-movements/pieces',
  //         queryParameters: queryParams,
  //         options: Options(headers: await ApiDioService().getAuthHeaders()),
  //       ),
  //     );

  //     if (ApiDioService.isSuccess(response)) {
  //       return (response.data);
  //     } else {
  //       throw Exception(
  //         'Erreur lors du chargement des pièces: ${response.data.toString()}',
  //       );
  //     }
  //   } on DioException catch (dioError) {
  //     if (kDebugMode) {
  //       print('erreur loading pieces = ${dioError.response?.data.toString()}');
  //     }
  //     throw _handleDioError(
  //       dioError,
  //       'Erreur lors du chargement des mouvements de stock',
  //     );
  //   } catch (e) {
  //     throw Exception(
  //       'Erreur inattendue lors du chargement des mouvements de stock: $e',
  //     );
  //   }
  // }

  Future<StockMovement> createMovement(Map<String, dynamic> data) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/stock-movements',
          data: data,
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (ApiDioService.isSuccess(response)) {
        return StockMovement.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Erreur lors de la création du mouvement de stock: ${response.statusCode}',
        );
      }
    } on DioException catch (dioError) {
      throw _handleDioError(
        dioError,
        'Erreur lors de la création du mouvement de stock',
      );
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors de la création du mouvement de stock: $e',
      );
    }
  }

  Future<StockMovement> getMovementById(String id) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/stock-movements/$id',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (ApiDioService.isSuccess(response)) {
        return StockMovement.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Erreur lors du chargement du mouvement de stock: ${response.statusCode}',
        );
      }
    } on DioException catch (dioError) {
      throw _handleDioError(
        dioError,
        'Erreur lors du chargement du mouvement de stock',
      );
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors du chargement du mouvement de stock: $e',
      );
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/client/check-email/$email',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );
      return response.statusCode == 200 ? response.data['exists'] : false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkPhoneExists(String phone) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/client/check-phone/$phone',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );
      return response.statusCode == 200 ? response.data['exists'] : false;
    } catch (e) {
      return false;
    }
  }

  // Méthode pour gérer les erreurs Dio de manière cohérente
  Exception _handleDioError(DioException dioError, String contextMessage) {
    debugPrint("Erreur détaillée Dio: ${dioError.response?.data.toString()}");
    debugPrint("Type d'erreur: ${dioError.type}");
    debugPrint("Message: ${dioError.message}");

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'La requête a expiré. Vérifiez votre connexion internet.',
        );

      case DioExceptionType.badResponse:
        final statusCode = dioError.response?.statusCode ?? 0;
        final message =
            dioError.response?.data?['message'] ??
            dioError.message ??
            'Erreur inconnue';

        if (statusCode == 400) {
          return Exception('Requête invalide : $message');
        } else if (statusCode == 401) {
          return Exception('Non autorisé. Veuillez vous reconnecter.');
        } else if (statusCode == 403) {
          return Exception(
            'Accès interdit. Vous n\'avez pas les permissions nécessaires.',
          );
        } else if (statusCode == 404) {
          return Exception('Ressource non trouvée : $message');
        } else if (statusCode >= 500) {
          return Exception('Erreur serveur ($statusCode) : $message');
        } else {
          return Exception('Erreur ($statusCode) : $message');
        }

      case DioExceptionType.cancel:
        return Exception('Requête annulée.');

      case DioExceptionType.unknown:
        if (dioError.error != null &&
            dioError.error.toString().contains('SocketException')) {
          return Exception(
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
          );
        }
        return Exception('Erreur réseau ou inconnue : ${dioError.message}');

      case DioExceptionType.connectionError:
        return Exception(
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        );

      case DioExceptionType.badCertificate:
        return Exception('Certificat de sécurité invalide.');
    }
  }
}
