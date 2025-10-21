import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'endpoint.dart';
import '../config/env_config.dart';

class ApiClient {
  late final Dio dio;
  final _secureStorage = const FlutterSecureStorage();

  ApiClient({String? baseUrl}) {
    final timeoutDuration = Duration(milliseconds: EnvConfig.apiTimeout);

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
        connectTimeout: timeoutDuration,
        receiveTimeout: timeoutDuration,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Platform': 'mobile', // Identify as mobile client
        },
      ),
    );

    // Add auth token interceptor - automatically injects token from secure storage
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip auth for login/register endpoints
          if (options.path.contains('/auth/login') ||
              options.path.contains('/auth/register')) {
            return handler.next(options);
          }

          // Load token from secure storage and inject into headers
          try {
            final token = await _secureStorage.read(key: 'auth_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              print('🔐 Token injected for: ${options.method} ${options.path}');
            } else {
              print('⚠️ No token found for: ${options.method} ${options.path}');
            }
          } catch (e) {
            print('❌ Error reading token: $e');
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          // Log auth errors
          if (error.response?.statusCode == 401) {
            print('🚫 Unauthorized request: ${error.requestOptions.path}');
          } else if (error.response?.statusCode == 403) {
            print('🚫 Forbidden request: ${error.requestOptions.path}');
          }
          return handler.next(error);
        },
      ),
    );

    // Add logger in debug mode
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );
  }

  // Set authorization token
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authorization token
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data['error'] ??
            error.response?.data['message'] ??
            'Server error';
        // Include status code in exception message for better error handling
        return Exception('[$statusCode] $message');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error: ${error.message}');
    }
  }
}
