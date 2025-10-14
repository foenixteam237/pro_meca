import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pro_meca/core/models/facture.dart';
import '../../../../services/dio_api_services.dart';

class FactureService {
  final Dio _dio;

  FactureService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiDioService().apiUrl,
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );

  Future<FactureResponse> getFactures({
    int skip = 0,
    int take = 10,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/factures',
          data: {'skip': skip, 'take': take, 'filters': filters},
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (ApiDioService.isSuccess(response)) {
        return FactureResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Erreur lors du chargement des factures: ${response.statusCode}',
        );
      }
    } on DioException catch (dioError) {
      throw _handleDioError(dioError, 'Erreur lors du chargement des factures');
    } catch (e) {
      throw Exception('Erreur inattendue lors du chargement des factures: $e');
    }
  }

  Future<Facture> getFacture(String id) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/factures/$id',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (ApiDioService.isSuccess(response)) {
        return Facture.fromJson(response.data['data']);
      } else {
        throw Exception('Erreur lors du chargement de la facture');
      }
    } on DioException catch (dioError) {
      throw _handleDioError(
        dioError,
        'Erreur lors du chargement de la facture',
      );
    } catch (e) {
      throw Exception('Erreur inattendue lors du chargement de la facture: $e');
    }
  }

  Future<bool> updateFactureStatus(String id, String status) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.patch(
          '/factures/$id/$status',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      return ApiDioService.isSuccess(response);
    } on DioException catch (dioError) {
      throw _handleDioError(
        dioError,
        'Erreur lors de la mise à jour du statut',
      );
    } catch (e) {
      throw Exception('Erreur inattendue lors de la mise à jour du statut: $e');
    }
  }

  Future<bool> deleteFacture(String id) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.delete(
          '/factures/$id',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      return ApiDioService.isSuccess(response);
    } on DioException catch (dioError) {
      throw _handleDioError(
        dioError,
        'Erreur lors de la suppression de la facture',
      );
    } catch (e) {
      throw Exception('Erreur inattendue lors de la suppression: $e');
    }
  }

  Future<Uint8List> generateWordFactureBytes(
    String visiteId, {
    int tva = 1,
    int ir = 0,
  }) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/factures/word/visite/$visiteId/$tva/$ir',
          options: Options(
            headers: await ApiDioService().getAuthHeaders(),
            responseType:
                ResponseType.bytes, // Important pour les fichiers binaires
          ),
        ),
      );

      if (ApiDioService.isSuccess(response)) {
        return response.data as Uint8List;
      } else {
        throw Exception('Erreur lors du téléchargement du fichier Word');
      }
    } on DioException catch (dioError) {
      throw _handleDioError(
        dioError,
        'Erreur lors du téléchargement du fichier Word',
      );
    } catch (e) {
      throw Exception('Erreur inattendue lors du téléchargement: $e');
    }
  }

  Future<bool> updateInterventionsOrdered(List<String> interventionIds) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/interventions/update-many',
          data: {'interventionIds': interventionIds, 'hasBeenOrdered': true},
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      return ApiDioService.isSuccess(response);
    } on DioException catch (dioError) {
      throw _handleDioError(
        dioError,
        'Erreur lors de la validation des interventions',
      );
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors de la validation des interventions: $e',
      );
    }
  }

  // Ajouter ces méthodes dans facture_services.dart
  Future<List<Client>> searchClients(String query) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/clients/search',
          queryParameters: {'q': query},
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (ApiDioService.isSuccess(response)) {
        return (response.data['data'] as List)
            .map((item) => Client.fromJson(item))
            .toList();
      } else {
        throw Exception('Erreur lors de la recherche des clients');
      }
    } on DioException catch (dioError) {
      throw _handleDioError(
        dioError,
        'Erreur lors de la recherche des clients',
      );
    } catch (e) {
      throw Exception('Erreur inattendue lors de la recherche des clients: $e');
    }
  }

  Future<Client> createClient(FormData clientData) async {
    try {
      if (kDebugMode) {
        print('clientData= $clientData');
      }
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/clients/create',
          data: clientData,
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (ApiDioService.isSuccess(response)) {
        if (kDebugMode) {
          print('Client créé: $response["data"]');
        }
        return Client.fromJson(response.data['data']);
      } else {
        throw Exception('Erreur lors de la création du client');
      }
    } on DioException catch (dioError) {
      throw _handleDioError(dioError, 'Erreur lors de la création du client');
    } catch (e) {
      throw Exception('Erreur inattendue lors de la création du client: $e');
    }
  }

  Future<Facture> createFacture(Map<String, dynamic> factureData) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/factures/create',
          data: factureData,
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (ApiDioService.isSuccess(response)) {
        return Facture.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Erreur lors de la création de la facture: ${response.statusCode}',
        );
      }
    } on DioException catch (dioError) {
      throw _handleDioError(
        dioError,
        'Erreur lors de la création de la facture',
      );
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors de la création de la facture: $e',
      );
    }
  }

  Future<Facture> updateFacture(
    String id,
    Map<String, dynamic> factureData,
  ) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.put(
          '/factures/$id',
          data: factureData,
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (ApiDioService.isSuccess(response)) {
        return Facture.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Erreur lors de la mise à jour de la facture: ${response.statusCode}',
        );
      }
    } on DioException catch (dioError) {
      throw _handleDioError(
        dioError,
        'Erreur lors de la mise à jour de la facture',
      );
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors de la mise à jour de la facture: $e',
      );
    }
  }

  // Méthode pour gérer les erreurs Dio de manière cohérente
  Exception _handleDioError(DioException dioError, String contextMessage) {
    debugPrint("Erreur détaillée Dio: $dioError");
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
