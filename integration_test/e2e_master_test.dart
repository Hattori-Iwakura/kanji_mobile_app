import 'package:flutter_test/flutter_test.dart';

// Import all test modules
import 'auth_test.dart' as auth;
import 'kanji_test.dart' as kanji;
import 'kanji_list_test.dart' as kanji_list;
import 'kanji_search_test.dart' as kanji_search;
import 'kanji_recognition_test.dart' as kanji_recognition;
import 'flashcard_deck_test.dart' as flashcard;
import 'quiz_test.dart' as quiz;
import 'quiz_question_test.dart' as quiz_question;
import 'quiz_attempt_test.dart' as quiz_attempt;
import 'quiz_publish_request_test.dart' as quiz_publish;

void main() {
  group('🧪 E2E Master Test Suite - Kanji Learning App', () {
    print('\n' + '=' * 80);
    print('🚀 Starting Full E2E Test Suite');
    print('📅 Date: ${DateTime.now()}');
    print('🎯 Target: All Integration Tests');
    print('=' * 80 + '\n');

    group('1️⃣  Authentication Module (13 tests)', auth.main);

    group('2️⃣  Kanji Module (8 tests)', kanji.main);

    group('3️⃣  Kanji List Module (13 tests)', kanji_list.main);

    group('4️⃣  Kanji Search Module (10 tests)', kanji_search.main);

    group('5️⃣  Kanji Recognition Module (5 tests)', kanji_recognition.main);

    group('6️⃣  Flashcard Deck Module (23 tests)', flashcard.main);

    group('7️⃣  Quiz CRUD Module (14 tests)', quiz.main);

    group('8️⃣  Quiz Question Management (12 tests)', quiz_question.main);

    group('9️⃣  Quiz Attempt Module (12 tests)', quiz_attempt.main);

    group('🔟 Quiz Publish Request (12 tests)', quiz_publish.main);
  });

  tearDownAll(() {
    print('\n' + '=' * 80);
    print('✅ E2E Test Suite Completed');
    print('📊 Check results above for detailed status');
    print('=' * 80 + '\n');
  });
}
