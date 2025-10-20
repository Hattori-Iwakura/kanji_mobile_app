import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_flutter/features/auth/models/auth_exception.dart';

void main() {
  group('AuthException Tests', () {
    test('should create AuthException with message', () {
      const message = 'Invalid credentials';
      final exception = AuthException(message);

      expect(exception.message, message);
    });

    test('should implement Exception interface', () {
      final exception = AuthException('Test error');
      expect(exception, isA<Exception>());
    });

    test('should handle empty message', () {
      const message = '';
      final exception = AuthException(message);

      expect(exception.message, '');
    });

    test('should handle long error messages', () {
      const message =
          'This is a very long error message that might occur '
          'when the backend returns detailed validation errors or '
          'multiple error messages concatenated together.';
      final exception = AuthException(message);

      expect(exception.message, message);
    });

    test('should be catchable as AuthException', () {
      expect(
        () => throw AuthException('Test error'),
        throwsA(isA<AuthException>()),
      );
    });

    test('should preserve message when caught', () {
      const errorMessage = 'Login failed';

      try {
        throw AuthException(errorMessage);
      } catch (e) {
        expect(e, isA<AuthException>());
        expect((e as AuthException).message, errorMessage);
      }
    });

    test('should handle special characters in message', () {
      const message = 'Error: User "test@example.com" not found!';
      final exception = AuthException(message);

      expect(exception.message, message);
    });

    test('should handle unicode characters in message', () {
      const message = 'Lỗi: Tài khoản không tồn tại 🚫';
      final exception = AuthException(message);

      expect(exception.message, message);
    });
  });
}
