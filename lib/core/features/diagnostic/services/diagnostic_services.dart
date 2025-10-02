import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/diagnostic_update.dart';
import 'package:pro_meca/core/models/maintenance_task.dart';
import 'package:pro_meca/core/models/type_intervention.dart';
import 'package:pro_meca/services/dio_api_services.dart';

class DiagnosticServices {
  final Dio _dio;
  DiagnosticServices()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiDioService().apiUrl,
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );
  //##########################---CREATION D'UN DIAGNOSTIC---#############################

  Future<bool> submitDiagnostic(Diagnostic diag, String accessToken) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/visites/diagnostics/create',
          data: diag.toJson(),
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(response.data);
        return false;
      }
    } on DioException catch (e) {
      print(e);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /*#############################Recupération des diagnostics d'une visite############################*/

  Future<List<Diagnostic>> fetchDiagnostic(String idVisite) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/visites/diagnostics/$idVisite',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        print(data);
        if (data is List) {
          return data.map((json) => Diagnostic.fromJson(json)).toList();
        }

        throw Exception("Format de réponse inattendu : ${data.runtimeType}");
      } else {
        throw Exception(
          "Erreur API: ${response.statusCode} - ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      throw Exception("Erreur Dio: ${e.message}");
    } catch (e) {
      throw Exception("Erreur inconnue: $e");
    }
  }

  /*#############################Recupération des types d'interventions############################*/

  Future<List<InterventionType>> fetchInterventionTypes() async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/int/types',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => InterventionType.fromJson(json)).toList();
        }

        throw Exception("Format de réponse inattendu : ${data.runtimeType}");
      } else {
        throw Exception(
          "Erreur API: ${response.statusCode} - ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      throw Exception("Erreur Dio: ${e.message}");
    } catch (e) {
      throw Exception("Erreur inconnue: $e");
    }
  }

  /*########################################### CREATION D'UNE MAINTENANCE TASK ################################################*/

  Future<bool> createMaintenanceTask(Map<String, dynamic> data) async {
    print(jsonEncode(data));
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/int/create/many',
          data: jsonEncode(data),
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Erreur ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      print(e);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<MaintenanceTask>> fetchIntervention(String visiteId) async {
    final currentDate = DateTime.now(); // 12:24 AM WAT, 08/09/2025

    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/int/visite/$visiteId',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<MaintenanceTask> tasks = data
            .map((json) => MaintenanceTask.fromVisiteJson(json))
            .toList();
        return tasks;
      } else {
        print('Erreur: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erreur lors de la requête: $e');
      return [];
    }
  }

  Future<bool> updateInterventionStatus(
    String interventionId,
    bool hasBeenOrdered,
  ) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.put(
          '/int/$interventionId',
          data: {"hasBeenOrdered": hasBeenOrdered},
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          'Échec de la mise à jour pour l\'intervention $interventionId: ${response.statusCode}',
        );

        return false;
      }
    } catch (e) {
      print('Erreur lors de la mise à jour: $e');

      return false;
    }
  }

  Future<bool> createReport({
    required Map<String, dynamic> report,
    required BuildContext context,
  }) async {
    try {

      print(jsonEncode(report));
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/reports/create',
          data: jsonEncode(report),
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print(
            'Rapport créé avec succès pour l\'intervention $report[\'interventionId\']',
          );
        }
        return true;
      } else {
        if (kDebugMode) {
          print(
            'Échec de la création du rapport: ${response.statusCode} - ${response.data}',
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur lors de la création du rapport: ${response.statusCode}",
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la création du rapport: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de la création du rapport: ${e.toString()}",
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return false;
    }
  }
}
