import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/features/profile/models/two_factor_models.dart';

void main() {
  group('TwoFactorSetupResponse', () {
    test('should create from valid JSON with data wrapper', () {
      final json = {
        'statusCode': 200,
        'data': {
          'secret': 'JBSWY3DPEHPK3PXP',
          'qrCodeUrl':
              'otpauth://totp/MyApp:user@example.com?secret=JBSWY3DPEHPK3PXP',
          'backupCodes': ['ABC123', 'DEF456', 'GHI789'],
        },
      };

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.secret, 'JBSWY3DPEHPK3PXP');
      expect(result.qrCodeUrl, contains('otpauth://totp'));
      expect(result.backupCodes, hasLength(3));
      expect(result.backupCodes[0], 'ABC123');
    });

    test('should create from valid JSON without data wrapper', () {
      final json = {
        'secret': 'TESTKEY123',
        'qrCodeUrl': 'otpauth://totp/test',
        'backupCodes': ['CODE1', 'CODE2'],
      };

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.secret, 'TESTKEY123');
      expect(result.qrCodeUrl, 'otpauth://totp/test');
      expect(result.backupCodes, hasLength(2));
    });

    test('should handle missing fields with defaults', () {
      final json = <String, dynamic>{};

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.secret, '');
      expect(result.qrCodeUrl, '');
      expect(result.backupCodes, isEmpty);
    });

    test('should handle null backupCodes', () {
      final json = {'secret': 'TEST', 'qrCodeUrl': 'test', 'backupCodes': null};

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.backupCodes, isEmpty);
    });

    test('should handle invalid backupCodes types', () {
      final json = {
        'secret': 'TEST',
        'qrCodeUrl': 'test',
        'backupCodes': ['valid', 123, null, true],
      };

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.backupCodes, hasLength(4));
      expect(result.backupCodes[0], 'valid');
      expect(result.backupCodes[1], '123');
      expect(result.backupCodes[2], 'null');
      expect(result.backupCodes[3], 'true');
    });
  });

  group('Enable2FARequest', () {
    test('should create request with code', () {
      final request = Enable2FARequest(code: '123456');

      expect(request.code, '123456');
    });

    test('should convert to JSON correctly', () {
      final request = Enable2FARequest(code: '654321');
      final json = request.toJson();

      expect(json, {'code': '654321'});
    });
  });

  group('Disable2FARequest', () {
    test('should create request with password and code', () {
      final request = Disable2FARequest(password: 'mypassword', code: '123456');

      expect(request.password, 'mypassword');
      expect(request.code, '123456');
    });

    test('should convert to JSON correctly', () {
      final request = Disable2FARequest(password: 'test123', code: '999999');
      final json = request.toJson();

      expect(json, {'password': 'test123', 'code': '999999'});
    });
  });

  group('TwoFactorResponse', () {
    test('should create from success response', () {
      final json = {
        'statusCode': 200,
        'data': {'message': 'Two-factor authentication enabled'},
      };

      final result = TwoFactorResponse.fromJson(json);

      expect(result.success, true);
      expect(result.message, 'Two-factor authentication enabled');
    });

    test('should create from 201 response', () {
      final json = {
        'statusCode': 201,
        'data': {'message': 'Created'},
      };

      final result = TwoFactorResponse.fromJson(json);

      expect(result.success, true);
    });

    test('should handle error status codes', () {
      final json = {
        'statusCode': 400,
        'data': {'message': 'Invalid code'},
      };

      final result = TwoFactorResponse.fromJson(json);

      expect(result.success, false);
      expect(result.message, 'Invalid code');
    });

    test('should handle missing message', () {
      final json = {'statusCode': 200, 'data': <String, dynamic>{}};

      final result = TwoFactorResponse.fromJson(json);

      expect(result.success, true);
      expect(result.message, 'Success');
    });

    test('should handle response without data wrapper', () {
      final json = {'statusCode': 200, 'message': 'Direct message'};

      final result = TwoFactorResponse.fromJson(json);

      expect(result.success, true);
      expect(result.message, 'Direct message');
    });
  });

  group('Type Safety Tests', () {
    test('should handle dynamic types in backupCodes', () {
      final json = {
        'secret': 'TEST',
        'qrCodeUrl': 'test',
        'backupCodes': ['string', 123, 45.67, true, false, null],
      };

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.backupCodes, isA<List<String>>());
      expect(result.backupCodes, hasLength(6));
      expect(result.backupCodes[0], 'string');
      expect(result.backupCodes[1], '123');
      expect(result.backupCodes[2], '45.67');
      expect(result.backupCodes[3], 'true');
      expect(result.backupCodes[4], 'false');
      expect(result.backupCodes[5], 'null');
    });

    test('should handle empty arrays safely', () {
      final json = {
        'secret': 'TEST',
        'qrCodeUrl': 'test',
        'backupCodes': <dynamic>[],
      };

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.backupCodes, isEmpty);
      expect(result.backupCodes, isA<List<String>>());
    });

    test('should handle wrong type for arrays', () {
      final json = {
        'secret': 'TEST',
        'qrCodeUrl': 'test',
        'backupCodes': 'not an array',
      };

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.backupCodes, isEmpty);
    });
  });

  group('Edge Cases', () {
    test('should handle very long secret keys', () {
      final longSecret = 'A' * 1000;
      final json = {
        'secret': longSecret,
        'qrCodeUrl': 'test',
        'backupCodes': [],
      };

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.secret, longSecret);
      expect(result.secret.length, 1000);
    });

    test('should handle special characters in QR URL', () {
      final specialUrl =
          'otpauth://totp/App:user@test.com?secret=ABC&issuer=Test%20App';
      final json = {
        'secret': 'ABC',
        'qrCodeUrl': specialUrl,
        'backupCodes': [],
      };

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.qrCodeUrl, specialUrl);
      expect(result.qrCodeUrl, contains('&'));
      expect(result.qrCodeUrl, contains('%20'));
    });

    test('should handle many backup codes', () {
      final manyCodes = List.generate(100, (i) => 'CODE$i');
      final json = {
        'secret': 'TEST',
        'qrCodeUrl': 'test',
        'backupCodes': manyCodes,
      };

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.backupCodes, hasLength(100));
      expect(result.backupCodes.first, 'CODE0');
      expect(result.backupCodes.last, 'CODE99');
    });

    test('should handle empty strings', () {
      final json = {
        'secret': '',
        'qrCodeUrl': '',
        'backupCodes': ['', '', ''],
      };

      final result = TwoFactorSetupResponse.fromJson(json);

      expect(result.secret, '');
      expect(result.qrCodeUrl, '');
      expect(result.backupCodes, hasLength(3));
      expect(result.backupCodes.every((code) => code.isEmpty), true);
    });
  });
}
