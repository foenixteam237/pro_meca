import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pro_meca/core/models/client.dart';
import 'package:pro_meca/core/models/vehicle.dart';
import 'package:pro_meca/core/models/visite.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      print('Response Status Code: ${formData.fields}');

      if (response.statusCode == 201) {
        final responseData = response.data;
        return Vehicle.fromJson(responseData['data']).id;
      } else {
        final errorData = response.data;
        print(formData.fields.toString());
        throw Exception(
          'Échec de la création du véhicule : ${errorData['message']}',
        );
      }
    } on DioException catch (e) {
      // Gérer l'erreur Dio
      if (e.response != null) {
        // La requête a été faite et le serveur a répondu avec un code d'erreur
        print('Erreur: ${e.response?.statusCode}');
        print('Détails: ${e.response?.data}');
      } else {
        // La requête n'a pas pu être effectuée
        print('Erreur: ${e.message}');
      }
    } catch (e) {
      // Gérer d'autres types d'erreurs
      print('Erreur inconnue: $e');
    }
  }

  //#################################"-CREATION D'UNE VISITE-"#############################"
  Future<int?> createVisite(
    Map<String, dynamic> visiteData,
    BuildContext context,
  ) async {
    try {
      print(
        "Les données de la visite sont" + json.encode(visiteData.toString()),
      );

      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/visites/create',
          data: visiteData,
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      print("La reponse du serveur est " + response.toString());
      switch (response.statusCode) {
        case 201:
          final responseData = response.data;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Votre véhicule est enregistré, merci de passer au diagnostic.",
              ),
            ),
          );
          return response.statusCode;
        default:
          debugPrint("Erreur non reconnue");
          return 0;
      }
    } on DioException catch (e) {
      // Gestion des erreurs spécifiques à Dio
      if (e.response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
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
