import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Kanji Module Integration Tests', () {
    late IntegrationTestHelper helper;

    setUpAll(() async {
      helper = IntegrationTestHelper();

      final isRunning = await helper.isBackendRunning();
      if (!isRunning) {
        throw Exception(
          'Backend server is not running! '
          'Please start it with: cd kanji-web-be && npm run start:dev',
        );
      }

      await helper.registerTestUser();
      await helper.loginAndGetToken();
    });

    tearDownAll(() async {
      await helper.cleanup();
    });

    test('Get kanji list - Success', () async {
      final response = await helper.apiClient.get('/kanji');

      expect(response.statusCode, 200);
      expect(response.data, isNotNull);

      // Backend wraps response in {statusCode, data: {data: [...], total, limit}, timestamp}
      final responseData = response.data['data'] ?? response.data;
      final kanjiList = responseData['data'] as List;

      expect(kanjiList, isA<List>());

      if (kanjiList.isNotEmpty) {
        final firstKanji = kanjiList[0];
        expect(firstKanji['id'], isNotNull);
        expect(firstKanji['character'], isNotNull);
        expect(firstKanji['meanings'], isNotNull);

        print('✅ Kanji list retrieved successfully');
        print('   Total kanji: ${responseData['total']}');
        print(
          '   First kanji: ${firstKanji['character']} - ${firstKanji['meanings']}',
        );
      }
    });

    test('Get kanji list with pagination', () async {
      final response = await helper.apiClient.get('/kanji?page=1&limit=10');

      expect(response.statusCode, 200);

      final responseData = response.data['data'] ?? response.data;
      final kanjiList = responseData['data'] as List;

      expect(kanjiList, isA<List>());
      expect(kanjiList.length, lessThanOrEqualTo(10));

      print('✅ Paginated kanji list retrieved successfully');
    });

    test('Get kanji list by JLPT level', () async {
      for (final level in [5, 4, 3, 2, 1]) {
        final response = await helper.apiClient.get(
          '/kanji?jlpt=$level&limit=10',
        );

        expect(response.statusCode, 200);

        final responseData = response.data['data'] ?? response.data;
        final kanjiList = responseData['data'] as List;

        expect(kanjiList, isA<List>());

        if (kanjiList.isNotEmpty) {
          // Verify all kanji have correct JLPT level
          for (final kanji in kanjiList) {
            expect(
              kanji['jlpt'],
              equals(level),
              reason:
                  'Kanji ${kanji['character']} should have JLPT level $level',
            );
          }
          print('✅ JLPT N$level kanji: ${kanjiList.length} found');
        } else {
          print('⚠️  JLPT N$level: No kanji found (might be empty in DB)');
        }
      }
    });

    test('Get kanji by ID - Success', () async {
      // First get a kanji to get valid ID
      final listResponse = await helper.apiClient.get('/kanji?limit=1');
      final listData = listResponse.data['data'] ?? listResponse.data;
      final kanjiList = listData['data'] as List;
      expect(kanjiList.isNotEmpty, true);

      final kanjiId = kanjiList[0]['id'];

      final response = await helper.apiClient.get('/kanji/$kanjiId');

      expect(response.statusCode, 200);

      final kanji = response.data['data'] ?? response.data;
      expect(kanji, isNotNull);
      expect(kanji['id'], equals(kanjiId));
      expect(kanji['character'], isNotNull);
      expect(kanji['meanings'], isNotNull);
      expect(kanji['onyomi'], isNotNull);
      expect(kanji['kunyomi'], isNotNull);

      print('✅ Kanji detail retrieved successfully');
      print('   Character: ${kanji['character']}');
      print('   Meaning: ${kanji['meanings']}');
      print('   On: ${kanji['onyomi']}');
      print('   Kun: ${kanji['kunyomi']}');
    });

    test('Get kanji by ID - Not found', () async {
      try {
        await helper.apiClient.get('/kanji/999999');
        fail('Should throw exception for non-existent kanji');
      } catch (e) {
        expect(e.toString(), contains('404'));
        print('✅ Correctly handled non-existent kanji');
      }
    });

    test('Search kanji by character - Success', () async {
      // Get a kanji first
      final listResponse = await helper.apiClient.get('/kanji?limit=1');
      final listData = listResponse.data['data'] ?? listResponse.data;
      final kanjiList = listData['data'] as List;
      final character = kanjiList[0]['character'];

      final response = await helper.apiClient.get(
        '/kanji/character/$character',
      );

      expect(response.statusCode, 200);

      final kanji = response.data['data'] ?? response.data;
      expect(kanji, isNotNull);
      expect(kanji['character'], equals(character));

      print('✅ Kanji search by character successful: $character');
    });

    test('Get kanji with stroke order data', () async {
      final listResponse = await helper.apiClient.get('/kanji?limit=1');
      final listData = listResponse.data['data'] ?? listResponse.data;
      final kanjiList = listData['data'] as List;
      final kanjiId = kanjiList[0]['id'];

      final response = await helper.apiClient.get('/kanji/$kanjiId');
      final kanji = response.data['data'] ?? response.data;

      expect(kanji['strokeCount'], isNotNull);
      expect(kanji['strokeCount'], greaterThan(0));

      print('✅ Kanji stroke data validated');
      print('   Stroke count: ${kanji['strokeCount']}');
    });

    test('Verify kanji data completeness', () async {
      final response = await helper.apiClient.get('/kanji?limit=5');
      final responseData = response.data['data'] ?? response.data;
      final kanjiList = responseData['data'] as List;

      for (final kanji in kanjiList) {
        // Required fields
        expect(kanji['id'], isNotNull, reason: 'ID should exist');
        expect(kanji['character'], isNotNull, reason: 'Character should exist');
        expect(kanji['meanings'], isNotNull, reason: 'Meanings should exist');
        expect(kanji['jlpt'], isNotNull, reason: 'JLPT level should exist');
        expect(
          kanji['strokeCount'],
          isNotNull,
          reason: 'Stroke count should exist',
        );

        // Validate JLPT level (backend uses numbers 1-5)
        expect(
          kanji['jlpt'],
          inInclusiveRange(1, 5),
          reason: 'JLPT level should be 1-5',
        );

        // Stroke count should be positive
        expect(
          kanji['strokeCount'],
          greaterThan(0),
          reason: 'Stroke count should be positive',
        );
      }

      print('✅ All kanji data complete and valid');
      print('   Validated ${kanjiList.length} kanji records');
    });
  });
}
