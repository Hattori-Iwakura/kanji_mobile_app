import '../../domain/entities/two_factor_setup.dart';

class TwoFactorSetupModel extends TwoFactorSetup {
  const TwoFactorSetupModel({
    required super.secret,
    required super.qrCodeUrl,
    required super.backupCodes,
  });

  factory TwoFactorSetupModel.fromJson(Map<String, dynamic> json) {
    return TwoFactorSetupModel(
      secret: json['secret'] as String,
      qrCodeUrl: json['qrCodeUrl'] as String,
      backupCodes: (json['backupCodes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'secret': secret,
      'qrCodeUrl': qrCodeUrl,
      'backupCodes': backupCodes,
    };
  }
}
