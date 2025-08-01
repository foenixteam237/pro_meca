
import 'package:dio/dio.dart';

import '../../../../services/dio_api_services.dart';

class VisiteService{
  final Dio _dio;
  VisiteService()
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiDioService().apiUrl,
      contentType: 'application/json',
      responseType: ResponseType.json,
    ),
  );

}