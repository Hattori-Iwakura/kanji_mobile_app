import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ApiClient - Singleton class quản lý HTTP requests đến Backend API
///
/// Chức năng:
/// - Khởi tạo Dio client với BaseOptions từ .env file
/// - Cấu hình timeout và headers mặc định
/// - Quản lý authentication token (JWT)
/// - Log requests và responses cho debugging
///
/// Sử dụng trong: Repository implementations để gọi API
class ApiClient {
  late final Dio _dio;

  /// Constructor: Khởi tạo Dio với config từ .env
  ApiClient() {
    // Đọc config từ .env file
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
    final connectionTimeout = int.parse(
      dotenv.env['CONNECTION_TIMEOUT'] ?? '30000',
    );
    final receiveTimeout = int.parse(dotenv.env['RECEIVE_TIMEOUT'] ?? '30000');

    // Khởi tạo Dio với BaseOptions
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl, // Base URL cho tất cả requests
        connectTimeout: Duration(
          milliseconds: connectionTimeout,
        ), // Timeout khi kết nối
        receiveTimeout: Duration(
          milliseconds: receiveTimeout,
        ), // Timeout khi nhận data
        headers: {
          'Content-Type': 'application/json', // Gửi JSON
          'Accept': 'application/json', // Nhận JSON
        },
      ),
    );

    // Thêm interceptor để log requests/responses (chỉ trong dev mode)
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  /// Getter để truy cập Dio instance
  Dio get dio => _dio;

  /// Thêm JWT token vào Authorization header
  /// Được gọi sau khi user login thành công
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Xóa JWT token khỏi Authorization header
  /// Được gọi khi user logout
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
