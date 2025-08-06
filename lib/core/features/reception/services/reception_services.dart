import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/commonUi/validationScreen.dart';
import 'package:pro_meca/core/features/reception/views/diagnosticScreen.dart';
import 'package:pro_meca/core/models/client.dart';
import 'package:pro_meca/core/models/vehicle.dart';
import 'package:pro_meca/core/models/visite.dart';
import 'package:pro_meca/services/dio_api_services.dart';

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
          return Client.fromJson(responseData['data']).id;
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
      debugPrint('Response Status Code: ${formData.fields}');

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

  Future<List<Vehicle>> fetchVehicles(BuildContext context, String plate) async {
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
  Future<int?> createVisite(
    Map<String, dynamic> visiteData,
    BuildContext context,
  ) async {
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
          bool? shouldNavigateToDiagnostic = await showDialog<bool>(
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
          );
          if (shouldNavigateToDiagnostic == true) {
            // Rediriger vers la page Diagnostic

            final responseData = response.data;
            final idVisite = Visite.fromJson(responseData['data']).id;
            debugPrint("La visite est $idVisite");
            Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => DiagnosticPage(idVisite: idVisite),
              ),
            );
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
          }
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
        debugPrint('Erreur de connexion : ${e.message}');
        return e.response!.statusCode;
      }
    } catch (e) {
      // Gestion des autres exceptions
      debugPrint('Une erreur est survenue : ${e.toString()}');
      return 0;
    }
  }
}
