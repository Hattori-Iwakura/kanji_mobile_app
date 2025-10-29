class TwoFactorSetupResponse {
  final String secret;
  final String qrCodeUrl;
  final List<String> backupCodes;

  TwoFactorSetupResponse({
    required this.secret,
    required this.qrCodeUrl,
    required this.backupCodes,
  });

  factory TwoFactorSetupResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    // Safe parsing for backupCodes array
    List<String> parseBackupCodes(dynamic value) {
      if (value == null) return [];
      if (value is! List) return [];
      return value.map((e) => e.toString()).toList();
    }

    return TwoFactorSetupResponse(
      secret: data['secret'] as String? ?? '',
      qrCodeUrl: data['qrCodeUrl'] as String? ?? '',
      backupCodes: parseBackupCodes(data['backupCodes']),
    );
  }
}

class Enable2FARequest {
  final String code;

  Enable2FARequest({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}

class Disable2FARequest {
  final String password;
  final String code;

  Disable2FARequest({required this.password, required this.code});

  Map<String, dynamic> toJson() => {'password': password, 'code': code};
}

class TwoFactorResponse {
  final String message;
  final bool success;

  TwoFactorResponse({required this.message, this.success = true});

  factory TwoFactorResponse.fromJson(Map<String, dynamic> json) {
    // Try to get message from data first, then from root
    final data = json['data'];
    String message = 'Success';

    if (data is Map<String, dynamic> && data['message'] != null) {
      message = data['message'] as String;
    } else if (json['message'] != null) {
      message = json['message'] as String;
    }

    return TwoFactorResponse(
      message: message,
      success: json['statusCode'] == 200 || json['statusCode'] == 201,
    );
  }
}
