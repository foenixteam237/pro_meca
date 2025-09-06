import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/global_report.dart';
import 'package:pro_meca/services/dio_api_services.dart';

class ReportService {
  final Dio _dio;

  ReportService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiDioService().apiUrl,
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );

  /// Récupérer le rapport global pour une visite
  Future<GlobalReport> fetchGlobalReport(
    BuildContext context,
    String visiteId,
  ) async {
    try {
      // Récupère les catégories simples
      final headers = await ApiDioService().getAuthHeaders();

      final response = await ApiDioService().authenticatedRequest(
        () => _dio.get(
          '/report/visite/$visiteId',
          options: Options(headers: headers),
        ),
      );

      return GlobalReport.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de récupérer le rapport global : $errorMessage",
          ),
        ),
      );
      debugPrint('Erreur Dio: ${e.response?.statusCode}: ${e.response?.data}');
      throw (errorMessage);
    } catch (e, stack) {
      debugPrint('Erreur inconnue: $e');
      debugPrint('StackTrace: $stack');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur inattendue lors de la récupération."),
        ),
      );
      throw ("Erreur inattendue");
    }
  }
}
