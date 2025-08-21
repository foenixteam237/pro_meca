import 'package:dio/dio.dart';
import 'package:pro_meca/core/models/diagnostic_update.dart';
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
      final response = await _dio.post(
        '/visites/diagnostics/create',
        data: diag.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
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
}
