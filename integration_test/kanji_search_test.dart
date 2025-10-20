import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Kanji Search Module Integration Tests', () {
    late IntegrationTestHelper helper;

    setUpAll(() async {
      helper = IntegrationTestHelper();

      // Check if backend server is running
      final isRunning = await helper.isBackendRunning();
      if (!isRunning) {
        throw Exception(
          'Backend server is not running! '
          'Please start it with: cd kanji-web-be && npm run start:dev',
        );
      }

      print('🚀 Starting Kanji Search Module Integration Tests');
    });

    tearDownAll(() async {
      await helper.cleanup();
    });

    test('Search kanji by text query - Success', () async {
      final response = await helper.apiClient.get(
        '/kanji/search',
        queryParameters: {'query': 'one'},
      );

      print('Search response: ${response.data}');

      expect(response.statusCode, 200);

      final responseData = response.data['data'] ?? response.data;
      expect(responseData, isNotNull);
      expect(responseData['data'], isA<List>());

      final results = responseData['data'] as List;
      expect(results.isNotEmpty, true);

      // Verify result structure
      final firstResult = results[0];
      expect(firstResult['character'], isNotNull);
      expect(firstResult['meanings'], isNotNull);
      expect(firstResult['onyomi'], isNotNull);
      expect(firstResult['kunyomi'], isNotNull);
      expect(firstResult['strokeCount'], isNotNull);

      print('✅ Search by text successful!');
      print('   Found ${results.length} results for "one"');
      print(
        '   First result: ${firstResult['character']} - ${firstResult['meanings']}',
      );
    });

    test('Search kanji by character - Success', () async {
      final response = await helper.apiClient.get(
        '/kanji/search',
        queryParameters: {'query': '一'},
      );

      final responseData = response.data['data'] ?? response.data;
      final results = responseData['data'] as List;

      expect(results.isNotEmpty, true);

      // Should find the exact character
      final found = results.any((k) => k['character'] == '一');
      expect(found, true);

      print('✅ Search by character successful!');
    });

    test('Search with JLPT filter - Success', () async {
      final response = await helper.apiClient.get(
        '/kanji/search',
        queryParameters: {
          'jlptLevels': [5], // JLPT N5
        },
      );

      final responseData = response.data['data'] ?? response.data;
      final results = responseData['data'] as List;

      expect(results.isNotEmpty, true);

      // Verify all results are JLPT N5
      for (final kanji in results) {
        expect(kanji['jlpt'], 5);
      }

      print('✅ JLPT filter successful!');
      print('   Found ${results.length} JLPT N5 kanji');
    });

    test('Search with stroke count range - Success', () async {
      final response = await helper.apiClient.get(
        '/kanji/search',
        queryParameters: {'minStrokes': 1, 'maxStrokes': 3},
      );

      final responseData = response.data['data'] ?? response.data;
      final results = responseData['data'] as List;

      expect(results.isNotEmpty, true);

      // Verify all results are within stroke range
      for (final kanji in results) {
        final strokes = kanji['strokeCount'] as int;
        expect(strokes, greaterThanOrEqualTo(1));
        expect(strokes, lessThanOrEqualTo(3));
      }

      print('✅ Stroke count filter successful!');
      print('   Found ${results.length} kanji with 1-3 strokes');
    });

    test('Search with pagination - Success', () async {
      // Get first page
      final page1Response = await helper.apiClient.get(
        '/kanji/search',
        queryParameters: {'page': 1, 'limit': 5},
      );

      final page1Data = page1Response.data['data'] ?? page1Response.data;
      final page1Results = page1Data['data'] as List;

      expect(page1Results.length, lessThanOrEqualTo(5));

      // Get second page
      final page2Response = await helper.apiClient.get(
        '/kanji/search',
        queryParameters: {'page': 2, 'limit': 5},
      );

      final page2Data = page2Response.data['data'] ?? page2Response.data;
      final page2Results = page2Data['data'] as List;

      // Verify different results
      if (page1Results.isNotEmpty && page2Results.isNotEmpty) {
        final firstChar1 = page1Results[0]['character'];
        final firstChar2 = page2Results[0]['character'];
        expect(firstChar1, isNot(equals(firstChar2)));
      }

      print('✅ Pagination successful!');
      print('   Page 1: ${page1Results.length} results');
      print('   Page 2: ${page2Results.length} results');
    });

    test('Search with sorting - Success', () async {
      final response = await helper.apiClient.get(
        '/kanji/search',
        queryParameters: {'sortBy': 'strokes', 'limit': 10},
      );

      final responseData = response.data['data'] ?? response.data;
      final results = responseData['data'] as List;

      if (results.length > 1) {
        // Verify sorted by strokes (ascending)
        for (int i = 0; i < results.length - 1; i++) {
          final current = results[i]['strokeCount'] as int;
          final next = results[i + 1]['strokeCount'] as int;
          expect(current, lessThanOrEqualTo(next));
        }
      }

      print('✅ Sorting successful!');
      print('   Results sorted by stroke count');
    });

    test('Search with multiple filters - Success', () async {
      final response = await helper.apiClient.get(
        '/kanji/search',
        queryParameters: {
          'query': 'day',
          'jlptLevels': [5],
          'minStrokes': 1,
          'maxStrokes': 5,
        },
      );

      final responseData = response.data['data'] ?? response.data;
      final results = responseData['data'] as List;

      // Verify all filters applied
      for (final kanji in results) {
        expect(kanji['jlpt'], 5);
        final strokes = kanji['strokeCount'] as int;
        expect(strokes, greaterThanOrEqualTo(1));
        expect(strokes, lessThanOrEqualTo(5));
      }

      print('✅ Multiple filters successful!');
      print('   Found ${results.length} results matching all criteria');
    });

    test('Search with no results - Empty list', () async {
      final response = await helper.apiClient.get(
        '/kanji/search',
        queryParameters: {'query': 'zzzzzzzznonexistent'},
      );

      final responseData = response.data['data'] ?? response.data;
      final results = responseData['data'] as List;

      expect(results.isEmpty, true);

      print('✅ No results handled correctly');
    });

    test('Search with grade filter - Success', () async {
      final response = await helper.apiClient.get(
        '/kanji/search',
        queryParameters: {
          'grades': [1], // Grade 1 (elementary)
        },
      );

      final responseData = response.data['data'] ?? response.data;
      final results = responseData['data'] as List;

      if (results.isNotEmpty) {
        // Verify all results are grade 1
        for (final kanji in results) {
          expect(kanji['grade'], 1);
        }
      }

      print('✅ Grade filter successful!');
      print('   Found ${results.length} grade 1 kanji');
    });

    test('Search returns metadata - Total, page info', () async {
      final response = await helper.apiClient.get(
        '/kanji/search',
        queryParameters: {'page': 1, 'limit': 10},
      );

      final responseData = response.data['data'] ?? response.data;

      // Check for metadata
      expect(responseData['total'], isNotNull);
      expect(responseData['total'], isA<int>());

      print('✅ Metadata returned correctly');
      print('   Total: ${responseData['total']}');
      print('   Limit: ${responseData['limit'] ?? 'N/A'}');
    });
  });
}
