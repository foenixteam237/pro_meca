import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pro_meca/core/models/client.dart';
import 'package:pro_meca/core/models/vehicle.dart';
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
  Future<String> createClient(Map<String, dynamic> clientData) async {

    final response = await ApiDioService().authenticatedRequest(
      () async => await _dio.post(
        '/clients/create',
        data: clientData,
        options: Options(headers: await ApiDioService().getAuthHeaders()),
      ),
    );
    print("On arrive ici avec la reponse ${response.toString()} ");
    switch (response.statusCode) {
      case 201:
        final responseData = response.data;
        return Client.fromJson(responseData['data']).id;
      case 400:
        final errorData = response.data;
        debugPrint(
          'Failed to create client: ${errorData['message'] ?? 'Unknown error'}',
        );
        return "";
      case 422:
        final errorData = response.data;
        debugPrint(
          'Failed to create client: ${errorData['message'] ?? 'Unknown error'}',
        );
        return "";
      default:
        debugPrint("Erreur non reconnu");
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
}
