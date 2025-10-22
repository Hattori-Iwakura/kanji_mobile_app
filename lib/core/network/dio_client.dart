import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';

class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  DioClient(this._secureStorage, this._logger) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _authInterceptor(),
      _loggingInterceptor(),
      _errorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  // Auth Interceptor - adds JWT token to requests
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip token for login/register endpoints
        if (options.path.contains('/auth/login') ||
            options.path.contains('/auth/register') ||
            options.path.contains('/auth/google') ||
            options.path.contains('/auth/facebook')) {
          return handler.next(options);
        }

        // Add access token to headers
        final token = await _secureStorage.read(
          key: AppConstants.keyAccessToken,
        );
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - try to refresh token
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken = await _secureStorage.read(
              key: AppConstants.keyRefreshToken,
            );
            if (refreshToken != null) {
              // Try to refresh token
              final response = await _dio.post(
                ApiEndpoints.refreshToken,
                data: {'refreshToken': refreshToken},
                options: Options(
                  headers: {'Authorization': 'Bearer $refreshToken'},
                ),
              );

              if (response.statusCode == 200) {
                // Save new tokens
                final newAccessToken = response.data['accessToken'];
                final newRefreshToken = response.data['refreshToken'];

                await _secureStorage.write(
                  key: AppConstants.keyAccessToken,
                  value: newAccessToken,
                );
                await _secureStorage.write(
                  key: AppConstants.keyRefreshToken,
                  value: newRefreshToken,
                );

                // Retry the original request with new token
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final retryResponse = await _dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              }
            }
          } catch (e) {
            _logger.e('Token refresh failed: $e');
            // Clear tokens and let the error propagate
            await _secureStorage.deleteAll();
          }
        }

        return handler.next(error);
      },
    );
  }

  // Logging Interceptor - logs requests and responses
  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d(
          'REQUEST[${options.method}] => PATH: ${options.path}\n'
          'Headers: ${options.headers}\n'
          'Query Parameters: ${options.queryParameters}\n'
          'Data: ${options.data}',
        );
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i(
          'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\n'
          'Data: ${response.data}',
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        _logger.e(
          'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}\n'
          'Message: ${error.message}\n'
          'Response: ${error.response?.data}',
        );
        return handler.next(error);
      },
    );
  }

  // Error Interceptor - handles common errors
  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        String errorMessage = 'An unknown error occurred';

        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Request timeout';
        } else if (error.type == DioExceptionType.connectionError) {
          errorMessage = 'No internet connection';
        } else if (error.response != null) {
          switch (error.response?.statusCode) {
            case 400:
              errorMessage = error.response?.data['message'] ?? 'Bad request';
              break;
            case 401:
              errorMessage = 'Unauthorized access';
              break;
            case 403:
              errorMessage = 'Access forbidden';
              break;
            case 404:
              errorMessage = 'Resource not found';
              break;
            case 500:
              errorMessage = 'Internal server error';
              break;
            case 503:
              errorMessage = 'Service unavailable';
              break;
            default:
              errorMessage = error.response?.data['message'] ?? errorMessage;
          }
        }

        // Create new error with formatted message
        final modifiedError = DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: errorMessage,
          message: errorMessage,
        );

        return handler.next(modifiedError);
      },
    );
  }

  // Cleanup
  void dispose() {
    _dio.close();
  }
}
