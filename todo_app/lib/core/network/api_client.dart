import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient(String baseUrl)
      : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        
        return handler.next(options);
      },
      onError: (e, handler) {
        // handle token expiration or 401
        return handler.next(e);
      },
    ));
  }
}
