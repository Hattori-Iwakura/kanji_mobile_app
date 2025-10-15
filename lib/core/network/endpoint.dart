class ApiEndpoints {
  static const baseUrl =
      "http://10.0.2.2:3000/api"; // Nếu chạy trên Android emulator

  static const login = "$baseUrl/auth/login";
  static const refreshMobile = "$baseUrl/auth/refresh/mobile";
  static const logout = "$baseUrl/auth/logout";
}
