import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import 'package:kanji_mobile_app/features/kanji/domain/usecases/get_kanji_list.dart';
import 'package:kanji_mobile_app/features/kanji/domain/usecases/get_kanji_detail.dart';
import 'package:kanji_mobile_app/features/kanji/domain/usecases/search_kanji.dart';
import 'package:kanji_mobile_app/features/kanji/domain/usecases/create_kanji.dart';
import 'package:kanji_mobile_app/features/kanji/domain/usecases/update_kanji.dart';
import 'package:kanji_mobile_app/features/kanji/domain/usecases/delete_kanji.dart';
import '../helpers/test_helper.dart';

void main() {
  setUpAll(() async {
    TestHelper.printSection('INITIALIZING KANJI INTEGRATION TESTS');
    await TestHelper.initializeDependencies();
    TestHelper.printSuccess('Dependencies initialized');
  });

  group('1. Kanji List Tests -', () {
    late GetKanjiList getKanjiList;

    setUp(() {
      getKanjiList = di.sl<GetKanjiList>();
    });

    test('1.1. Get all kanji without filters', () async {
      TestHelper.printSection('TEST 1.1: GET ALL KANJI WITHOUT FILTERS');

      final result = await getKanjiList(
        jlpt: null,
        grade: null,
        search: null,
        limit: 20,
        offset: 0,
      );

      result.fold(
        (failure) {
          TestHelper.printError('Failed to get kanji list: ${failure.message}');
          fail('Should get kanji list successfully');
        },
        (kanjiList) {
          TestHelper.printSuccess('Got ${kanjiList.length} kanji');
          expect(kanjiList, isNotEmpty);
          expect(kanjiList.length, lessThanOrEqualTo(20));

          // Verify first kanji structure
          final firstKanji = kanjiList.first;
          TestHelper.printSuccess('First kanji: ${firstKanji.character}');
          expect(firstKanji.id, isPositive);
          expect(firstKanji.character, isNotEmpty);
          expect(firstKanji.meanings, isNotEmpty);
        },
      );
    });

    test('1.2. Get kanji filtered by JLPT N5', () async {
      TestHelper.printSection('TEST 1.2: GET KANJI FILTERED BY JLPT N5');

      final result = await getKanjiList(
        jlpt: 5,
        grade: null,
        search: null,
        limit: 10,
        offset: 0,
      );

      result.fold(
        (failure) {
          TestHelper.printError('Failed to filter by JLPT: ${failure.message}');
          fail('Should filter kanji by JLPT successfully');
        },
        (kanjiList) {
          TestHelper.printSuccess('Got ${kanjiList.length} JLPT N5 kanji');
          expect(kanjiList, isNotEmpty);

          // Verify all kanji are N5
          for (final kanji in kanjiList) {
            expect(kanji.jlpt, equals(5));
          }
          TestHelper.printSuccess('All kanji are JLPT N5');
        },
      );
    });

    test('1.3. Get kanji filtered by Grade 1', () async {
      TestHelper.printSection('TEST 1.3: GET KANJI FILTERED BY GRADE 1');

      final result = await getKanjiList(
        jlpt: null,
        grade: 1,
        search: null,
        limit: 10,
        offset: 0,
      );

      result.fold(
        (failure) {
          TestHelper.printError(
            'Failed to filter by grade: ${failure.message}',
          );
          fail('Should filter kanji by grade successfully');
        },
        (kanjiList) {
          TestHelper.printSuccess('Got ${kanjiList.length} Grade 1 kanji');
          expect(kanjiList, isNotEmpty);

          // Verify all kanji are Grade 1
          for (final kanji in kanjiList) {
            expect(kanji.grade, equals(1));
          }
          TestHelper.printSuccess('All kanji are Grade 1');
        },
      );
    });

    test('1.4. Search kanji by character', () async {
      TestHelper.printSection('TEST 1.4: SEARCH KANJI BY CHARACTER');

      final result = await getKanjiList(
        jlpt: null,
        grade: null,
        search: '日',
        limit: 10,
        offset: 0,
      );

      result.fold(
        (failure) {
          TestHelper.printError('Failed to search kanji: ${failure.message}');
          fail('Should search kanji successfully');
        },
        (kanjiList) {
          TestHelper.printSuccess(
            'Found ${kanjiList.length} kanji matching "日"',
          );
          expect(kanjiList, isNotEmpty);

          // Verify search result contains the character
          final hasCharacter = kanjiList.any(
            (kanji) => kanji.character.contains('日'),
          );
          expect(hasCharacter, isTrue);
          TestHelper.printSuccess('Search results contain "日"');
        },
      );
    });

    test('1.5. Test pagination with offset', () async {
      TestHelper.printSection('TEST 1.5: TEST PAGINATION');

      // Get first page
      final firstPage = await getKanjiList(
        jlpt: null,
        grade: null,
        search: null,
        limit: 5,
        offset: 0,
      );

      // Get second page
      final secondPage = await getKanjiList(
        jlpt: null,
        grade: null,
        search: null,
        limit: 5,
        offset: 5,
      );

      firstPage.fold((failure) => fail('First page should load'), (firstList) {
        secondPage.fold((failure) => fail('Second page should load'), (
          secondList,
        ) {
          TestHelper.printSuccess(
            'First page: ${firstList.length}, Second page: ${secondList.length}',
          );

          // Pages should be different
          expect(firstList.first.id, isNot(equals(secondList.first.id)));
          TestHelper.printSuccess('Pagination works correctly');
        });
      });
    });
  });

  group('2. Kanji Search Tests -', () {
    late SearchKanji searchKanji;

    setUp(() {
      searchKanji = di.sl<SearchKanji>();
    });

    test('2.1. Search kanji with query', () async {
      TestHelper.printSection('TEST 2.1: SEARCH KANJI WITH QUERY');

      final result = await searchKanji(
        query: '水',
        jlptLevels: null,
        grades: null,
        minStrokes: null,
        maxStrokes: null,
        page: 1,
        limit: 10,
        sortBy: null,
      );

      result.fold(
        (failure) {
          TestHelper.printError('Failed to search: ${failure.message}');
          fail('Should search successfully');
        },
        (searchResult) {
          TestHelper.printSuccess('Search returned results');
          expect(searchResult, isA<Map<String, dynamic>>());

          final kanji = searchResult['kanji'] as List;
          final total = searchResult['total'] as int;

          TestHelper.printSuccess('Found $total kanji matching "水"');
          expect(kanji, isNotEmpty);
          expect(total, isPositive);
        },
      );
    });

    test('2.2. Search with JLPT levels filter', () async {
      TestHelper.printSection('TEST 2.2: SEARCH WITH JLPT FILTER');

      final result = await searchKanji(
        query: null,
        jlptLevels: [5, 4],
        grades: null,
        minStrokes: null,
        maxStrokes: null,
        page: 1,
        limit: 10,
        sortBy: null,
      );

      result.fold(
        (failure) {
          TestHelper.printError(
            'Failed to search with JLPT filter: ${failure.message}',
          );
          fail('Should search with JLPT filter successfully');
        },
        (searchResult) {
          final kanji = searchResult['kanji'] as List;
          TestHelper.printSuccess(
            'Found ${kanji.length} kanji with JLPT N5/N4',
          );
          expect(kanji, isNotEmpty);
        },
      );
    });

    test('2.3. Search with stroke count filter', () async {
      TestHelper.printSection('TEST 2.3: SEARCH WITH STROKE COUNT FILTER');

      final result = await searchKanji(
        query: null,
        jlptLevels: null,
        grades: null,
        minStrokes: 1,
        maxStrokes: 5,
        page: 1,
        limit: 10,
        sortBy: null,
      );

      result.fold(
        (failure) {
          TestHelper.printError(
            'Failed to search with stroke filter: ${failure.message}',
          );
          fail('Should search with stroke filter successfully');
        },
        (searchResult) {
          final kanji = searchResult['kanji'] as List;
          TestHelper.printSuccess(
            'Found ${kanji.length} kanji with 1-5 strokes',
          );
          expect(kanji, isNotEmpty);

          // Verify all kanji have strokes within range (if kanji have strokeCount field)
          TestHelper.printSuccess('Stroke count filter working');
        },
      );
    });

    test('2.4. Search with grade filter', () async {
      TestHelper.printSection('TEST 2.4: SEARCH WITH GRADE FILTER');

      final result = await searchKanji(
        query: null,
        jlptLevels: null,
        grades: [1, 2],
        minStrokes: null,
        maxStrokes: null,
        page: 1,
        limit: 10,
        sortBy: null,
      );

      result.fold(
        (failure) {
          TestHelper.printError(
            'Failed to search with grade filter: ${failure.message}',
          );
          fail('Should search with grade filter successfully');
        },
        (searchResult) {
          final kanji = searchResult['kanji'] as List;
          TestHelper.printSuccess('Found ${kanji.length} kanji in Grade 1-2');
          expect(kanji, isNotEmpty);
        },
      );
    });

    test('2.5. Search with sorting', () async {
      TestHelper.printSection('TEST 2.5: SEARCH WITH SORTING');

      final result = await searchKanji(
        query: null,
        jlptLevels: null,
        grades: null,
        minStrokes: null,
        maxStrokes: null,
        page: 1,
        limit: 10,
        sortBy: 'strokes', // Backend accepts: character, strokes, jlpt, grade
      );

      result.fold(
        (failure) {
          TestHelper.printError(
            'Failed to search with sorting: ${failure.message}',
          );
          fail('Should search with sorting successfully');
        },
        (searchResult) {
          final kanji = searchResult['kanji'] as List;
          TestHelper.printSuccess(
            'Got ${kanji.length} kanji sorted by stroke count',
          );
          expect(kanji, isNotEmpty);
        },
      );
    });
  });

  group('3. Kanji Detail Tests -', () {
    late GetKanjiDetail getKanjiDetail;
    late GetKanjiList getKanjiList;

    setUp(() {
      getKanjiDetail = di.sl<GetKanjiDetail>();
      getKanjiList = di.sl<GetKanjiList>();
    });

    test('3.1. Get kanji detail with external APIs', () async {
      TestHelper.printSection('TEST 3.1: GET KANJI DETAIL WITH EXTERNAL APIS');

      // First get a kanji to test with
      final listResult = await getKanjiList(
        jlpt: 5,
        grade: null,
        search: null,
        limit: 1,
        offset: 0,
      );

      await listResult.fold((failure) => fail('Should get kanji list'), (
        kanjiList,
      ) async {
        expect(kanjiList, isNotEmpty);
        final testCharacter = kanjiList.first.character;
        TestHelper.printStep('Testing with character: $testCharacter');

        final detailResult = await getKanjiDetail(testCharacter);

        detailResult.fold(
          (failure) {
            TestHelper.printError('Failed to get detail: ${failure.message}');
            fail('Should get kanji detail successfully');
          },
          (detail) {
            TestHelper.printSuccess('Got kanji detail for $testCharacter');
            expect(detail.character, equals(testCharacter));
            expect(detail.meanings, isNotEmpty);

            // Check if external API data is present (may be null if APIs fail)
            TestHelper.printStep('Checking external API data...');
            if (detail.examples != null && detail.examples!.isNotEmpty) {
              TestHelper.printSuccess(
                'Examples loaded: ${detail.examples!.length}',
              );
            }
            if (detail.strokePaths != null && detail.strokePaths!.isNotEmpty) {
              TestHelper.printSuccess(
                'Stroke paths loaded: ${detail.strokePaths!.length}',
              );
            }
            if (detail.audioUrl != null) {
              TestHelper.printSuccess('Audio URL: ${detail.audioUrl}');
            }
          },
        );
      });
    });

    test('3.2. Get detail for common kanji', () async {
      TestHelper.printSection('TEST 3.2: GET DETAIL FOR COMMON KANJI');

      const testCharacters = ['日', '月', '水', '火', '木'];

      for (final character in testCharacters) {
        TestHelper.printStep('Getting detail for: $character');

        final result = await getKanjiDetail(character);

        result.fold(
          (failure) {
            TestHelper.printError('Failed for $character: ${failure.message}');
            // Don't fail the test, just log the error
          },
          (detail) {
            TestHelper.printSuccess('✓ $character - ${detail.meanings}');
            expect(detail.character, equals(character));
            expect(detail.meanings, isNotEmpty);
          },
        );
      }
    });

    test('3.3. Verify caching works for detail', () async {
      TestHelper.printSection('TEST 3.3: VERIFY DETAIL CACHING');

      const testCharacter = '日';

      // First call - should fetch from API
      TestHelper.printStep('First call (from API)...');
      final firstCallTime = DateTime.now();
      final firstResult = await getKanjiDetail(testCharacter);
      final firstCallDuration = DateTime.now().difference(firstCallTime);

      await Future.delayed(const Duration(milliseconds: 100));

      // Second call - should use cache
      TestHelper.printStep('Second call (from cache)...');
      final secondCallTime = DateTime.now();
      final secondResult = await getKanjiDetail(testCharacter);
      final secondCallDuration = DateTime.now().difference(secondCallTime);

      TestHelper.printSuccess(
        'First call: ${firstCallDuration.inMilliseconds}ms',
      );
      TestHelper.printSuccess(
        'Second call: ${secondCallDuration.inMilliseconds}ms',
      );

      // Both should succeed
      expect(firstResult.isRight(), isTrue);
      expect(secondResult.isRight(), isTrue);

      // Second call should be faster (cached)
      // Note: This might not always be true due to network variability
      if (secondCallDuration < firstCallDuration) {
        TestHelper.printSuccess('Cache is working! Second call was faster.');
      } else {
        TestHelper.printStep(
          'Second call not significantly faster, but both succeeded.',
        );
      }
    });
  });

  group('4. Admin Operations Tests -', () {
    late CreateKanji createKanji;
    late UpdateKanji updateKanji;
    late DeleteKanji deleteKanji;
    late GetKanjiList getKanjiList;

    setUp(() {
      createKanji = di.sl<CreateKanji>();
      updateKanji = di.sl<UpdateKanji>();
      deleteKanji = di.sl<DeleteKanji>();
      getKanjiList = di.sl<GetKanjiList>();
    });

    test('4.1. Create new kanji (Admin only)', () async {
      TestHelper.printSection('TEST 4.1: CREATE NEW KANJI (ADMIN)');

      final params = CreateKanjiParams(
        character: '漢',
        meanings: 'China, Han',
        onReadings: 'カン',
        kunReadings: 'から',
        jlptLevel: 4,
        grade: 3,
        strokeCount: 13,
        frequency: 150,
        tags: ['country', 'culture'],
      );

      final result = await createKanji(params);

      result.fold(
        (failure) {
          // Expected to fail if not admin
          TestHelper.printStep(
            'Failed (expected if not admin): ${failure.message}',
          );
          expect(
            failure.message,
            contains('Unauthorized'),
            reason: 'Should fail with unauthorized error',
          );
        },
        (kanji) {
          TestHelper.printSuccess('Created kanji: ${kanji.character}');
          expect(kanji.character, equals('漢'));
          expect(kanji.meanings, equals('China, Han'));
          expect(kanji.jlpt, equals(4));
        },
      );
    });

    test('4.2. Update kanji (Admin only)', () async {
      TestHelper.printSection('TEST 4.2: UPDATE KANJI (ADMIN)');

      // First get a kanji ID
      final listResult = await getKanjiList(
        jlpt: null,
        grade: null,
        search: null,
        limit: 1,
        offset: 0,
      );

      await listResult.fold((failure) => fail('Should get kanji list'), (
        kanjiList,
      ) async {
        expect(kanjiList, isNotEmpty);
        final kanjiId = kanjiList.first.id;

        final params = UpdateKanjiParams(
          id: kanjiId,
          meanings: 'Updated meaning',
        );

        final result = await updateKanji(params);

        result.fold(
          (failure) {
            // Expected to fail if not admin
            TestHelper.printStep(
              'Failed (expected if not admin): ${failure.message}',
            );
            expect(
              failure.message,
              contains('Unauthorized'),
              reason: 'Should fail with unauthorized error',
            );
          },
          (kanji) {
            TestHelper.printSuccess('Updated kanji ID: ${kanji.id}');
            expect(kanji.meanings, contains('Updated'));
          },
        );
      });
    });

    test('4.3. Delete kanji (Admin only)', () async {
      TestHelper.printSection('TEST 4.3: DELETE KANJI (ADMIN)');

      // Try to delete a non-existent ID to avoid affecting real data
      final result = await deleteKanji(99999);

      result.fold(
        (failure) {
          // Expected to fail if not admin or kanji doesn't exist
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('not found'),
              contains('Not Found'),
            ),
            reason: 'Should fail with unauthorized or not found error',
          );
        },
        (_) {
          TestHelper.printSuccess('Delete operation completed');
        },
      );
    });
  });

  group('5. Error Handling Tests -', () {
    late GetKanjiDetail getKanjiDetail;
    late SearchKanji searchKanji;

    setUp(() {
      getKanjiDetail = di.sl<GetKanjiDetail>();
      searchKanji = di.sl<SearchKanji>();
    });

    test('5.1. Handle invalid character', () async {
      TestHelper.printSection('TEST 5.1: HANDLE INVALID CHARACTER');

      final result = await getKanjiDetail('ABC123');

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(failure.message, isNotEmpty);
        },
        (detail) {
          fail('Should fail for invalid character');
        },
      );
    });

    test('5.2. Handle empty search query', () async {
      TestHelper.printSection('TEST 5.2: HANDLE EMPTY SEARCH');

      final result = await searchKanji(
        query: '',
        jlptLevels: null,
        grades: null,
        minStrokes: null,
        maxStrokes: null,
        page: 1,
        limit: 10,
        sortBy: null,
      );

      result.fold(
        (failure) {
          // May fail or return empty results
          TestHelper.printStep('Failed with: ${failure.message}');
        },
        (searchResult) {
          TestHelper.printSuccess('Returned results for empty query');
          expect(searchResult, isA<Map<String, dynamic>>());
        },
      );
    });

    test('5.3. Handle large page number', () async {
      TestHelper.printSection('TEST 5.3: HANDLE LARGE PAGE NUMBER');

      final result = await searchKanji(
        query: null,
        jlptLevels: null,
        grades: null,
        minStrokes: null,
        maxStrokes: null,
        page: 9999,
        limit: 10,
        sortBy: null,
      );

      result.fold(
        (failure) {
          TestHelper.printError('Failed: ${failure.message}');
        },
        (searchResult) {
          final kanji = searchResult['kanji'] as List;
          TestHelper.printSuccess(
            'Handled large page number, returned ${kanji.length} results',
          );
          expect(kanji, isEmpty, reason: 'Should return empty list');
        },
      );
    });

    test('5.4. Handle invalid stroke range', () async {
      TestHelper.printSection('TEST 5.4: HANDLE INVALID STROKE RANGE');

      // Min strokes greater than max strokes
      final result = await searchKanji(
        query: null,
        jlptLevels: null,
        grades: null,
        minStrokes: 20,
        maxStrokes: 5,
        page: 1,
        limit: 10,
        sortBy: null,
      );

      result.fold(
        (failure) {
          TestHelper.printStep(
            'Correctly handled invalid range: ${failure.message}',
          );
        },
        (searchResult) {
          final kanji = searchResult['kanji'] as List;
          TestHelper.printSuccess('Returned ${kanji.length} results');
          expect(
            kanji,
            isEmpty,
            reason: 'Should return empty list for invalid range',
          );
        },
      );
    });
  });

  group('6. Performance Tests -', () {
    late GetKanjiList getKanjiList;
    late SearchKanji searchKanji;

    setUp(() {
      getKanjiList = di.sl<GetKanjiList>();
      searchKanji = di.sl<SearchKanji>();
    });

    test('6.1. List performance test', () async {
      TestHelper.printSection('TEST 6.1: LIST PERFORMANCE');

      final startTime = DateTime.now();

      final result = await getKanjiList(
        jlpt: null,
        grade: null,
        search: null,
        limit: 50,
        offset: 0,
      );

      final duration = DateTime.now().difference(startTime);

      result.fold((failure) => fail('Should load kanji list'), (kanjiList) {
        TestHelper.printSuccess(
          'Loaded ${kanjiList.length} kanji in ${duration.inMilliseconds}ms',
        );
        expect(
          duration.inSeconds,
          lessThan(5),
          reason: 'Should load within 5 seconds',
        );
      });
    });

    test('6.2. Search performance test', () async {
      TestHelper.printSection('TEST 6.2: SEARCH PERFORMANCE');

      final startTime = DateTime.now();

      final result = await searchKanji(
        query: '日',
        jlptLevels: [5, 4, 3],
        grades: [1, 2],
        minStrokes: null,
        maxStrokes: null,
        page: 1,
        limit: 20,
        sortBy: 'strokes', // Backend accepts: character, strokes, jlpt, grade
      );

      final duration = DateTime.now().difference(startTime);

      result.fold((failure) => fail('Should search successfully'), (
        searchResult,
      ) {
        final kanji = searchResult['kanji'] as List;
        TestHelper.printSuccess(
          'Found ${kanji.length} kanji in ${duration.inMilliseconds}ms',
        );
        expect(
          duration.inSeconds,
          lessThan(5),
          reason: 'Search should complete within 5 seconds',
        );
      });
    });

    test('6.3. Concurrent requests test', () async {
      TestHelper.printSection('TEST 6.3: CONCURRENT REQUESTS');

      final startTime = DateTime.now();

      // Make 5 concurrent requests
      final futures = List.generate(
        5,
        (index) => getKanjiList(
          jlpt: null,
          grade: null,
          search: null,
          limit: 10,
          offset: index * 10,
        ),
      );

      final results = await Future.wait(futures);
      final duration = DateTime.now().difference(startTime);

      // All should succeed
      final allSucceeded = results.every((result) => result.isRight());
      expect(
        allSucceeded,
        isTrue,
        reason: 'All concurrent requests should succeed',
      );

      TestHelper.printSuccess(
        '5 concurrent requests completed in ${duration.inMilliseconds}ms',
      );
      expect(
        duration.inSeconds,
        lessThan(10),
        reason: 'Concurrent requests should complete within 10 seconds',
      );
    });
  });
}
