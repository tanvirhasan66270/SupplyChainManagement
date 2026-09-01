
import 'package:dio/dio.dart';
import 'package:scm_flutter/service/storageService.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class ApiClient {

final StorageService _storageService;
late final Dio dio;

ApiClient(this._storageService) {
  dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );


  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final isPublicRoute = error.requestOptions.path.contains('/api/country') ||
              error.requestOptions.path.contains('/api/division') ||
              error.requestOptions.path.contains('/api/district') ||
              error.requestOptions.path.contains('/api/policestation');
          if (!isPublicRoute) {
            await _storageService.clearSession();
          }
        }
        handler.next(error);
      },
    ),
  );
}


}


/// Normalizes Dio/backend errors into a readable message, similar to how
/// the Angular login component branched on `err.status`.
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    final data = error.response?.data;

    if (data is String && data.isNotEmpty) return data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }


    switch (status) {

      case 401:
        return 'Invalid email or password.';
      case 403:
        return 'Your account is not verified or has been disabled.';
      case 404:
        return 'Not found.';
      case null:
        return 'Could not reach the server. Check your connection / API URL.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}