import 'package:dio/dio.dart';
import 'package:pro_meca/core/models/diagnostic_update.dart';
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
    print(diag.toJson());
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
}
