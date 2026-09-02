import 'package:dio/dio.dart';
import 'package:flutter_template/core/helper/secure_storage_service.dart';

/// Attaches the stored access token as a Bearer header on every request.
///
/// Takes [SecureStorageService] via constructor injection rather than
/// resolving it itself, matching the DI convention in this repo — wire it
/// up in `authenticatedDioProvider` (not the shared unauthenticated Dio).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorageService);

  final SecureStorageService _secureStorageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
