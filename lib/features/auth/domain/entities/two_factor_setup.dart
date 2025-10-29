import 'package:equatable/equatable.dart';

class TwoFactorSetup extends Equatable {
  final String secret;
  final String qrCodeUrl;
  final List<String> backupCodes;

  const TwoFactorSetup({
    required this.secret,
    required this.qrCodeUrl,
    required this.backupCodes,
  });

  @override
  List<Object?> get props => [secret, qrCodeUrl, backupCodes];
}
