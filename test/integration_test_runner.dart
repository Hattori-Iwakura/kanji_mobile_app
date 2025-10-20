import 'package:flutter_test/flutter_test.dart';
import '../integration_test/auth_test.dart' as auth_tests;
import '../integration_test/kanji_test.dart' as kanji_tests;
import '../integration_test/kanji_list_test.dart' as kanji_list_tests;
import '../integration_test/kanji_recognition_test.dart' as recognition_tests;

void main() {
  group('All Integration Tests', () {
    print('\n' + '=' * 80);
    print('🚀 INTEGRATION TESTS - Requires Backend & ML Server Running');
    print('=' * 80);
    print('Backend: http://localhost:3000');
    print('ML Server: http://localhost:8000 (via backend proxy)');
    print('=' * 80 + '\n');

    group('Auth Module', auth_tests.main);
    group('Kanji Module', kanji_tests.main);
    group('Kanji List Module', kanji_list_tests.main);
    group('Kanji Recognition Module', recognition_tests.main);
  });
}
