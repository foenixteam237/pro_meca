import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/commonUi/validationScreen.dart';
import 'package:pro_meca/core/features/diagnostic/views/diagnosticScreen.dart';
import 'package:pro_meca/core/models/vehicle.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/brand.dart';
import '../../../models/modele.dart';
import '../../../models/visite.dart';
import '../../../widgets/show_modal_bottm.dart';

class ReceptionServices {
  final Dio _dio;
  ReceptionServices()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiDioService().apiUrl,
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );

  Future<List<Brand>> getAllBrands() async {
    final response = await ApiDioService().authenticatedRequest(
      () async => await _dio.get(
        '/brands',
        options: Options(headers: await ApiDioService().getAuthHeaders()),
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
    final response = await ApiDioService().authenticatedRequest(
      () async => await _dio.get(
        '/brands/$brandId',
        options: Options(headers: await ApiDioService().getAuthHeaders()),
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

  //#################################--CREATION D'UN NOUVEAU CLIENT LORS DE LA RECEPTION--###############################
  Future<String> createClient(
    Map<String, dynamic> clientData,
    BuildContext context,
  ) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/clients/create',
          data: FormData.fromMap(clientData),
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      switch (response.statusCode) {
        case 201:
          final responseData = response.data;
          return responseData['data']['id'];
        default:
          debugPrint("Erreur non reconnue");
          return "";
      }
    } on DioException catch (e) {
      // Gestion des erreurs spécifiques à Dio
      if (e.response != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // ignore: prefer_interpolation_to_compose_strings
              "Nous n'avons pas créer l'utilisateur car " +
                  e.response?.data['message'],
            ),
          ),
        );

        debugPrint('Erreur ${e.response?.statusCode}: ${e.response?.data}');
        return "";
      } else {
        // Si aucune réponse n'a été reçue, c'est un problème de connexion ou autre
        debugPrint('Erreur de connexion : ${e.message}');
        return "";
      }
    } catch (e) {
      // Gestion des autres exceptions
      debugPrint('Une erreur est survenue : ${e.toString()}');
      return "";
    }
  }

  //##################################--CREATION D'UN VEHICULE--#########################
  Future<String?> createVehicle(FormData formData) async {
    final apiService = ApiDioService();
    try {
      final response = await apiService.authenticatedRequest(
        () async => _dio.post(
          '/vehicles/create',
          data: formData,
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        return Vehicle.fromJson(responseData['data']).id;
      } else {
        final errorData = response.data;
        debugPrint(formData.fields.toString());
        throw Exception(
          'Échec de la création du véhicule : ${errorData['message']}',
        );
      }
    } on DioException catch (e) {
      // Gérer l'erreur Dio
      if (e.response != null) {
        // La requête a été faite et le serveur a répondu avec un code d'erreur
        debugPrint('Erreur: ${e.response?.statusCode}');
        debugPrint('Détails: ${e.response?.data}');
        return null;
      } else {
        // La requête n'a pas pu être effectuée
        debugPrint('Erreur: ${e.message}');
        return null;
      }
    } catch (e) {
      // Gérer d'autres types d'erreurs
      debugPrint('Erreur inconnue: $e');
      return null;
    }
  }

  //##################################"-RECUPERATION DE LA LISTE DES VEHICULE-"#########################################

  Future<List<Vehicle>> fetchVehicles(
    BuildContext context,
    String plate,
  ) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/vehicles/license-plate/$plate',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        debugPrint("Erreur lors de la récupération des véhicules");
        return [];
      }
    } on DioException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de récupérer les véhicules. ${e.response?.data['message'] ?? e.message}",
          ),
        ),
      );
      debugPrint('Erreur Dio: ${e.response?.statusCode}: ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('Erreur: ${e.toString()}');
      return [];
    }
  }

  //#################################"-CREATION D'UNE VISITE-"#############################"
  Future<int?> createVisite(FormData visiteData, BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final accessToken = pref.getString("accessToken");
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/visites/create',
          data: visiteData,
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      switch (response.statusCode) {
        case 201:
      /*
         bool shouldNavigateToDiagnosticS =
              await showDialog<bool>(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (context) => AlertDialog(
                  actionsAlignment: MainAxisAlignment.center,
                  title: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "Souhaitez-vous passer directement au diagnostic ?",
                      style: AppStyles.bodyMedium(context),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false), // Non
                      child: const Text("Non"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true), // Oui
                      child: const Text("Oui"),
                    ),
                  ],
                ),
              ) ??
              false;
         bool shouldNavigateToDiagnostic = false;
          if (shouldNavigateToDiagnostic) {
            try {
              final responseData = response.data;

              // Vérifier que les données nécessaires existent
              if (responseData?['data']?['id'] == null) {
                throw Exception(
                  'ID de visite manquant dans la réponse du serveur',
                );
              }

              final visiteId = responseData['data']['id'];
              print('ID de visite reçu: $visiteId');

              // Récupérer les détails de la visite
              Visite visite = await fetchVisiteWithVehicle(visiteId);
              print('Visite récupérée: ${visite.id}');

              // Naviguer vers la page Diagnostic
              // ignore: use_build_context_synchronously
              if (visite.id.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiagnosticPage(
                      idVisite: visite.id,
                      visite: visite,
                      accessToken: accessToken,
                    ),
                  ),
                );
              } else {
                showPieceSelectionModal(
                  context,
                  ConfirmationScreen(
                    message:
                        "Votre véhicule a été enregistré avec succès, mais nous n'avons pas pu récupérer les détails de la visite pour le diagnostic.",
                  ),
                );
              }
            } catch (e, stackTrace) {
              print('Erreur lors de la récupération de la visite: $e');
              print('Stack trace: $stackTrace');

              // Afficher une alerte à l'utilisateur
              // ignore: use_build_context_synchronously
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Erreur'),
                  content: Text(
                    'Impossible de récupérer les détails de la visite: ${e.toString()}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          } else {
            // Rediriger vers la page ConfirmationScreen
            Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmationScreen(
                  message: "Votre véhicule a été enregistré avec succès",
                ),
              ),
            );

            /*
            showPieceSelectionModal(
              context,
              ConfirmationScreen(
                message: "Votre véhicule a été enregistré avec succès",
              ),
            );*/
            /*Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmationScreen(
                  message: "Votre véhicule a été enregistré avec succès",
                ),
              ),
            );*/
          }*/
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmationScreen(
                message: "Votre véhicule a été enregistré avec succès",
              ),
            ),
          );
          return response.statusCode;
        case 400:
          print(response.data["message"]);
          return response.statusCode;
        default:
          debugPrint("Erreur non reconnue");
          return 0;
      }
    } on DioException catch (e) {
      // Gestion des erreurs spécifiques à Dio
      if (e.response != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // ignore: prefer_interpolation_to_compose_strings
              "Nous n'avons pas pu créer la visite car " +
                  (e.response?.data['message'] ?? 'Erreur inconnue'),
            ),
          ),
        );
        debugPrint('Erreur ${e.response?.statusCode}: ${e.response?.data}');
        return 0;
      } else {
        // Si aucune réponse n'a été reçue, c'est un problème de connexion ou autre
        debugPrint('Erreur de connexions : ${e.toString()}');
        return e.response!.statusCode;
      }
    } catch (e) {
      // Gestion des autres exceptions
      debugPrint('Une erreur est survenue : ${e.toString()}');
      return 0;
    }
  }

  //##################################################-RECUPERATION DES VISITES AVEC LA VEHICULE INCLU-###################################
  Future<List<Visite>> fetchVisitesWithVehicle() async {
    debugPrint("Je suis dans fetchVisitesWithVehicle");
    try {
      // 1. Récupère les visites avec timeout et gestion d'erreur
      final Response resVisite = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/visites',
          options: Options(
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: await ApiDioService().getAuthHeaders(),
          ),
        ),
      );

      if (kDebugMode) {
        print("visites listing =$resVisite");
      }

      // Vérification du statut HTTP ET du champ success dans la réponse
      if (resVisite.statusCode != 200) {
        // Tentative de récupération du message d'erreur du serveur
        final dynamic responseData = resVisite.data;
        String errorMessage = 'Statut HTTP ${resVisite.statusCode}';

        if (responseData is Map && responseData.containsKey('message')) {
          errorMessage = responseData['message'] ?? errorMessage;
        } else if (responseData is Map &&
            responseData.containsKey('success') &&
            responseData['success'] == false) {
          errorMessage =
              responseData['message'] ?? 'Erreur serveur sans message';
        }

        throw DioException(
          requestOptions: resVisite.requestOptions,
          response: resVisite,
          error: errorMessage,
        );
      }

      // Vérification supplémentaire du champ success si la réponse est un Map
      final dynamic responseData = resVisite.data;
      if (responseData is Map &&
          responseData.containsKey('success') &&
          responseData['success'] == false) {
        final String errorMessage =
            responseData['message'] ?? 'Erreur serveur sans message détaillé';
        throw DioException(
          requestOptions: resVisite.requestOptions,
          response: resVisite,
          error: errorMessage,
        );
      }

      // Conversion en List seulement si c'est bien une liste
      final List<dynamic> visites;
      if (responseData is List) {
        visites = responseData;
      } else if (responseData is Map &&
          responseData.containsKey('data') &&
          responseData['data'] is List) {
        visites = responseData['data'] as List;
      } else {
        throw Exception('Format de réponse inattendu');
      }

      if (kDebugMode) {
        print("visites listing =$visites");
      }

      // 2. Récupération parallèle des véhicules
      final List<Visite> result = await Future.wait(
        visites.map((visiteJson) async {
          try {
            final vehicleId = visiteJson['vehicleId'].toString();
            final Response resVehicle = await _dio.get(
              '/vehicles/$vehicleId',
              options: Options(
                receiveTimeout: const Duration(seconds: 10),
                headers: await ApiDioService().getAuthHeaders(),
              ),
            );

            // Gestion des erreurs pour les véhicules
            if (resVehicle.statusCode != 200) {
              final dynamic vehicleResponseData = resVehicle.data;
              String vehicleErrorMessage =
                  'Erreur véhicule ${resVehicle.statusCode}';

              if (vehicleResponseData is Map &&
                  vehicleResponseData.containsKey('message')) {
                vehicleErrorMessage =
                    vehicleResponseData['message'] ?? vehicleErrorMessage;
              } else if (vehicleResponseData is Map &&
                  vehicleResponseData.containsKey('success') &&
                  vehicleResponseData['success'] == false) {
                vehicleErrorMessage =
                    vehicleResponseData['message'] ??
                    'Erreur véhicule sans message';
              }

              throw DioException(
                requestOptions: resVehicle.requestOptions,
                response: resVehicle,
                error: vehicleErrorMessage,
              );
            }

            // Vérification du champ success pour les véhicules
            final dynamic vehicleData = resVehicle.data;
            if (vehicleData is Map &&
                vehicleData.containsKey('success') &&
                vehicleData['success'] == false) {
              final String errorMessage =
                  vehicleData['message'] ??
                  'Erreur véhicule sans message détaillé';
              throw DioException(
                requestOptions: resVehicle.requestOptions,
                response: resVehicle,
                error: errorMessage,
              );
            }

            final Vehicle vehicle = Vehicle.fromJson(
              vehicleData as Map<String, dynamic>,
            );

            return Visite.fromVisiteJson(visiteJson, vehicle);
          } on DioException catch (e) {
            // En cas d'erreur sur un véhicule, on log l'erreur et retourne une visite partielle
            debugPrint(
              'Erreur véhicule pour vehicleId ${visiteJson['vehicleId']}: ${e.message}',
            );
            // Retourne une visite avec les données de base sans le véhicule
            return Visite.fromJson(visiteJson);
          }
        }),
      );

      return result;
    } on DioException catch (e) {
      debugPrint('Erreur réseau: ${e.message}');
      if (e.response != null) {
        final dynamic errorData = e.response?.data;
        String serverMessage = 'Pas de message';

        // Extraction du message d'erreur du serveur
        if (errorData is Map && errorData.containsKey('message')) {
          serverMessage = errorData['message'] ?? serverMessage;
        } else if (errorData is Map &&
            errorData.containsKey('success') &&
            errorData['success'] == false) {
          serverMessage = errorData['message'] ?? 'Erreur serveur sans message';
        }

        throw Exception(
          'Erreur serveur (${e.response?.statusCode}): $serverMessage',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout de connexion au serveur');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      debugPrint('Erreur inattendue: $e');
      throw Exception('Erreur lors du chargement des visites');
    }
  }

  //##################################################-RECUPERATION D'UNE VISITE AVEC LA VEHICULE INCLU-###################################
  Future<Visite> fetchVisiteWithVehicle(String visiteId) async {
    try {
      // 1. Récupérer la visite par son ID
      final Response resVisite = await _dio.get(
        '/visites/$visiteId',
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: await ApiDioService().getAuthHeaders(),
        ),
      );

      if (resVisite.statusCode != 200) {
        throw DioException(
          requestOptions: resVisite.requestOptions,
          response: resVisite,
          error: 'Statut HTTP ${resVisite.statusCode}',
        );
      }
      debugPrint(resVisite.data);
      return Visite.fromVisiteJson(resVisite.data, Vehicle.fromJson(resVisite.data['vehicle']));
    } on DioException catch (e) {
      debugPrint('Erreur réseau: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Erreur serveur (${e.response?.statusCode}): ${e.response?.data['message'] ?? 'Pas de message'}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout de connexion au serveur');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      debugPrint('Erreur inattendue: $e');
      throw Exception('Erreur lors du chargement de la visite');
    }
  }

  //##################################################-RECUPERATION DES VISITES AVEC LA VEHICULE INCLU-###################################

  Future<List<Visite>> fetchVisitesWithVehicleStatus(String status) async {
    try {
      // 1. Récupère les visites avec timeout et gestion d'erreur
      final Response resVisite = await _dio.get(
        '/visites/status/$status',
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: await ApiDioService().getAuthHeaders(),
        ),
      );

      if (resVisite.statusCode != 200) {
        throw DioException(
          requestOptions: resVisite.requestOptions,
          response: resVisite,
          error: 'Statut HTTP ${resVisite.statusCode}',
        );
      }

      final List<dynamic> visites = resVisite.data as List;

      // 2. Récupération parallèle des véhicules
      final List<Visite> result = await Future.wait(
        visites.map((visiteJson) async {
          try {
            final vehicleId = visiteJson['vehicleId'] as String;
            final Response resVehicle = await _dio.get(
              '/vehicles/$vehicleId',
              options: Options(
                receiveTimeout: const Duration(seconds: 10),
                headers: await ApiDioService().getAuthHeaders(),
              ),
            );
            if (resVehicle.statusCode != 200) {
              throw DioException(
                requestOptions: resVehicle.requestOptions,
                response: resVehicle,
                error: 'Erreur véhicule ${resVehicle.statusCode}',
              );
            }

            final Vehicle vehicle = Vehicle.fromJson(
              resVehicle.data as Map<String, dynamic>,
            );

            return Visite.fromVisiteJson(visiteJson, vehicle);
          } on DioException catch (e) {
            // En cas d'erreur sur un véhicule, retourne une visite partielle
            debugPrint('Erreur véhicule : ${e.message}');
            return Visite.fromJson(visiteJson);
          }
        }),
      );

      return result;
    } on DioException catch (e) {
      debugPrint('Erreur réseau: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Erreur serveur (${e.response?.statusCode}): ${e.response?.data['message'] ?? 'Pas de message'}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout de connexion au serveur');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      debugPrint('Erreur inattendue: $e');
      throw Exception('Erreur lors du chargement des visites');
    }
  }

  Future<List<Visite>> fetchVisitesWithVehicleStatusAndUser(
    String status,
  ) async {
    try {
      // 1. Récupère les visites avec timeout et gestion d'erreur
      final Response resVisite = await _dio.get(
        '/visites/status/user/$status',
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: await ApiDioService().getAuthHeaders(),
        ),
      );

      if (resVisite.statusCode != 200) {
        throw DioException(
          requestOptions: resVisite.requestOptions,
          response: resVisite,
          error: 'Statut HTTP ${resVisite.statusCode}',
        );
      }

      final List<dynamic> visites = resVisite.data as List;

      // 2. Récupération parallèle des véhicules
      final List<Visite> result = await Future.wait(
        visites.map((visiteJson) async {
          try {
            final vehicleId = visiteJson['vehicleId'] as String;
            final Response resVehicle = await _dio.get(
              '/vehicles/$vehicleId',
              options: Options(
                receiveTimeout: const Duration(seconds: 10),
                headers: await ApiDioService().getAuthHeaders(),
              ),
            );
            if (resVehicle.statusCode != 200) {
              throw DioException(
                requestOptions: resVehicle.requestOptions,
                response: resVehicle,
                error: 'Erreur véhicule ${resVehicle.statusCode}',
              );
            }

            final Vehicle vehicle = Vehicle.fromJson(
              resVehicle.data as Map<String, dynamic>,
            );

            return Visite.fromVisiteJson(visiteJson, vehicle);
          } on DioException catch (e) {
            // En cas d'erreur sur un véhicule, retourne une visite partielle
            debugPrint('Erreur véhicule : ${e.message}');
            return Visite.fromJson(visiteJson);
          }
        }),
      );

      return result;
    } on DioException catch (e) {
      debugPrint('Erreur réseau: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Erreur serveur (${e.response?.statusCode}): ${e.response?.data['message'] ?? 'Pas de message'}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout de connexion au serveur');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      debugPrint('Erreur inattendue: $e');
      throw Exception('Erreur lors du chargement des visites');
    }
  }

  Future<void> deleteVisite(String id) async {
    final apiDioService = ApiDioService();

    try {
      final response = await apiDioService.authenticatedRequest(
        () async => await _dio.delete(
          '/visites/$id',
          options: Options(headers: await apiDioService.getAuthHeaders()),
        ),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Erreur API : ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Erreur Dio : ${e.message}");
    } catch (e) {
      throw Exception("Erreur inattendue : ${e.toString()}");
    }
  }

  ///A utiliser pour récupérer les statistiques d'une visite mais après
  Future<Map<String, dynamic>> getVisiteStats(String id) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/visites/status/$id',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Erreur API : ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Erreur Dio : ${e.message}");
    }
  }
}
