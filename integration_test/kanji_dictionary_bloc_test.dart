import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:kanji_flutter/features/kanji/presentation/bloc/kanji_bloc.dart';
import 'package:kanji_flutter/features/kanji/presentation/bloc/kanji_event.dart';
import 'package:kanji_flutter/features/kanji/presentation/bloc/kanji_state.dart';
import 'package:kanji_flutter/injection_container.dart' as di;
import 'package:kanji_flutter/core/network/api_client.dart';
import 'package:kanji_flutter/main.dart' as app;
import 'package:get_it/get_it.dart';

import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Kanji Dictionary Bloc Flow Tests', () {
    late IntegrationTestHelper testHelper;
    late ApiClient apiClient;

    setUpAll(() async {
      // Load environment variables
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        print('⚠️ Could not load .env file: $e');
      }

      await di.init();
      testHelper = IntegrationTestHelper();
      apiClient = di.sl<ApiClient>();

      final isRunning = await testHelper.isBackendRunning();
      if (!isRunning) {
        throw Exception(
          '❌ Backend not running at ${IntegrationTestHelper.baseUrl}',
        );
      }
      print('✅ Backend server is running');
    });

    tearDownAll(() async {
      try {
        await testHelper.cleanup();
      } catch (e) {
        print('⚠️ Cleanup error: $e');
      }
    });

    group('Kanji Bloc - Dictionary Load Tests', () {
      blocTest<KanjiBloc, KanjiState>(
        '✅ Load kanji dictionary should emit KanjiListLoaded',
        build: () => di.sl<KanjiBloc>(),
        act: (bloc) => bloc.add(LoadKanjiListEvent(limit: 10)),
        expect: () => [
          isA<KanjiLoading>(),
          isA<KanjiListLoaded>().having(
            (state) => state.kanjiList.length,
            'kanji count',
            greaterThan(0),
          ),
        ],
        wait: const Duration(seconds: 5),
      );

      blocTest<KanjiBloc, KanjiState>(
        '✅ Filter by JLPT level should return filtered list',
        build: () => di.sl<KanjiBloc>(),
        act: (bloc) => bloc.add(LoadKanjiListEvent(jlptLevel: 'N5', limit: 10)),
        expect: () => [isA<KanjiLoading>(), isA<KanjiListLoaded>()],
        verify: (bloc) {
          final state = bloc.state;
          if (state is KanjiListLoaded) {
            // Verify all kanji have N5 level
            for (var kanji in state.kanjiList) {
              if (kanji.jlptLevel != null) {
                expect(kanji.jlptLevel, equals('N5'));
              }
            }
          }
        },
        wait: const Duration(seconds: 5),
      );

      blocTest<KanjiBloc, KanjiState>(
        '✅ Filter by grade should return filtered list',
        build: () => di.sl<KanjiBloc>(),
        act: (bloc) => bloc.add(LoadKanjiListEvent(grade: 1, limit: 10)),
        expect: () => [isA<KanjiLoading>(), isA<KanjiListLoaded>()],
        verify: (bloc) {
          final state = bloc.state;
          if (state is KanjiListLoaded) {
            // Verify all kanji have grade 1
            for (var kanji in state.kanjiList) {
              if (kanji.grade != null) {
                expect(kanji.grade, equals(1));
              }
            }
          }
        },
        wait: const Duration(seconds: 5),
      );

      blocTest<KanjiBloc, KanjiState>(
        '✅ Refresh should reload kanji list',
        build: () => di.sl<KanjiBloc>(),
        seed: () {
          // Seed with initial loaded state
          final bloc = di.sl<KanjiBloc>();
          bloc.add(LoadKanjiListEvent(limit: 5));
          return KanjiListLoaded(kanjiList: [], currentPage: 1, hasMore: false);
        },
        act: (bloc) => bloc.add(LoadKanjiListEvent(limit: 5)),
        expect: () => [isA<KanjiLoading>(), isA<KanjiListLoaded>()],
        wait: const Duration(seconds: 5),
      );
    });

    group('Kanji Dictionary - UI Integration Tests', () {
      testWidgets(
        '✅ Dictionary page should display kanji grid [SKIPPED - Requires emulator]',
        (WidgetTester tester) async {
          await testHelper.loginAndGetToken();

          // Reset GetIt and reinitialize for widget test
          await GetIt.instance.reset();
          await di.init();

          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to dictionary (assuming it's accessible from home)
          await tester.pumpAndSettle();

          // Verify grid is displayed
          expect(find.byType(GridView), findsWidgets);
        },
        skip: true,
      ); // Requires emulator/device - GetIt registration conflict

      testWidgets(
        '✅ Admin should see add button in dictionary [SKIPPED - Requires emulator]',
        (WidgetTester tester) async {
          await testHelper.loginAsAdmin();

          // Reset GetIt and reinitialize for widget test
          await GetIt.instance.reset();
          await di.init();

          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Look for add button (admin only)
          final addButton = find.byIcon(Icons.add);
          expect(addButton, findsOneWidget);
        },
        skip: true,
      ); // Requires emulator/device

      testWidgets(
        '✅ Regular user should NOT see add button [SKIPPED - Requires emulator]',
        (WidgetTester tester) async {
          await testHelper.loginAndGetToken();

          // Reset GetIt and reinitialize for widget test
          await GetIt.instance.reset();
          await di.init();

          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Add button should not exist for regular users
          final addButton = find.byIcon(Icons.add);
          expect(addButton, findsNothing);
        },
        skip: true,
      ); // Requires emulator/device

      testWidgets(
        '✅ Refresh button should reload data [SKIPPED - Requires emulator]',
        (WidgetTester tester) async {
          await testHelper.loginAndGetToken();

          // Reset GetIt and reinitialize for widget test
          await GetIt.instance.reset();
          await di.init();

          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Find and tap refresh button
          final refreshButton = find.byIcon(Icons.refresh);
          expect(refreshButton, findsOneWidget);

          await tester.tap(refreshButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verify grid still displays
          expect(find.byType(GridView), findsWidgets);
        },
        skip: true,
      ); // Requires emulator/device

      testWidgets(
        '✅ Filter button should show filter dialog [SKIPPED - Requires emulator]',
        (WidgetTester tester) async {
          await testHelper.loginAndGetToken();

          // Reset GetIt and reinitialize for widget test
          await GetIt.instance.reset();
          await di.init();

          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Find and tap filter FAB
          final filterButton = find.byIcon(Icons.filter_list);
          expect(filterButton, findsOneWidget);

          await tester.tap(filterButton);
          await tester.pumpAndSettle();

          // Verify dialog is shown
          expect(find.text('Filter Kanji'), findsOneWidget);
          expect(find.text('JLPT Level'), findsOneWidget);
          expect(find.text('Grade'), findsOneWidget);
        },
        skip: true,
      ); // Requires emulator/device
    });

    group('Kanji Create - Form Validation Tests', () {
      testWidgets(
        '❌ Create form should validate empty character field [SKIPPED - Requires emulator]',
        (WidgetTester tester) async {
          await testHelper.loginAsAdmin();

          // Reset GetIt and reinitialize for widget test
          await GetIt.instance.reset();
          await di.init();

          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to create page
          final addButton = find.byIcon(Icons.add);
          await tester.tap(addButton);
          await tester.pumpAndSettle();

          // Try to submit without filling character
          final createButton = find.text('Create');
          await tester.tap(createButton);
          await tester.pumpAndSettle();

          // Should show validation error
          expect(find.text('Please enter a character'), findsOneWidget);
        },
        skip: true,
      ); // Requires emulator/device

      testWidgets(
        '❌ Create form should validate character length [SKIPPED - Requires emulator]',
        (WidgetTester tester) async {
          await testHelper.loginAsAdmin();

          // Reset GetIt and reinitialize for widget test
          await GetIt.instance.reset();
          await di.init();

          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to create page
          final addButton = find.byIcon(Icons.add);
          await tester.tap(addButton);
          await tester.pumpAndSettle();

          // Enter multiple characters (should only allow 1)
          final characterField = find.byType(TextField).first;
          await tester.enterText(characterField, '漢字');
          await tester.pumpAndSettle();

          // Try to submit
          final createButton = find.text('Create');
          await tester.tap(createButton);
          await tester.pumpAndSettle();

          // Should show validation error
          expect(
            find.textContaining('must be exactly 1 character'),
            findsOneWidget,
          );
        },
        skip: true,
      ); // Requires emulator/device

      testWidgets(
        '❌ Create form should validate empty meanings [SKIPPED - Requires emulator]',
        (WidgetTester tester) async {
          await testHelper.loginAsAdmin();

          // Reset GetIt and reinitialize for widget test
          await GetIt.instance.reset();
          await di.init();

          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to create page
          final addButton = find.byIcon(Icons.add);
          await tester.tap(addButton);
          await tester.pumpAndSettle();

          // Fill only character
          final fields = find.byType(TextField);
          await tester.enterText(fields.at(0), '学');
          await tester.pumpAndSettle();

          // Try to submit
          final createButton = find.text('Create');
          await tester.tap(createButton);
          await tester.pumpAndSettle();

          // Should show validation error for meanings
          expect(find.textContaining('Please enter meanings'), findsOneWidget);
        },
        skip: true,
      ); // Requires emulator/device
    });

    group('Kanji Create - API Integration Tests', () {
      test('✅ Create kanji via API should succeed', () async {
        await testHelper.loginAsAdmin();

        final testKanji = {
          'character': '試',
          'onyomi': ['シ'],
          'kunyomi': ['ため.す', 'こころ.みる'],
          'meanings': ['test', 'trial', 'examination'],
          'strokeCount': 13,
          'jlptLevel': 'N3',
          'grade': 4,
        };

        try {
          final response = await apiClient.post('/kanji', data: testKanji);
          print('📥 Create Kanji Response: ${response.data}');

          expect(response.statusCode, equals(201));
          expect(response.data, isNotNull);

          // Unwrap response
          final wrappedData = response.data as Map<String, dynamic>;
          expect(wrappedData.containsKey('data'), isTrue);

          final createdKanji = wrappedData['data'];
          expect(createdKanji['character'], equals('試'));
          expect(createdKanji['id'], isNotNull);

          print('✅ Kanji created successfully with ID: ${createdKanji['id']}');

          // Cleanup: Delete the test kanji
          await apiClient.delete('/kanji/${createdKanji['id']}');
          print('🗑️ Cleaned up test kanji');
        } catch (e) {
          print('❌ Create kanji failed: $e');
          rethrow;
        }
      });

      test('❌ Create duplicate kanji should fail', () async {
        await testHelper.loginAsAdmin();

        // First, get an existing kanji
        final listResponse = await apiClient.get('/kanji?limit=1');
        final wrappedData = listResponse.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        List<dynamic> kanjiList = [];
        if (actualData is Map<String, dynamic>) {
          kanjiList = (actualData['data'] as List?) ?? [];
        } else if (actualData is List) {
          kanjiList = actualData;
        }

        expect(kanjiList.length, greaterThan(0));

        final existingKanji = kanjiList.first;
        final duplicateData = {
          'character': existingKanji['character'],
          'onyomi': ['テスト'],
          'kunyomi': ['てすと'],
          'meanings': ['duplicate test'],
          'strokeCount': 1,
        };

        try {
          await apiClient.post('/kanji', data: duplicateData);
          fail('Should throw error for duplicate kanji');
        } catch (e) {
          print('✅ Correctly rejected duplicate kanji: $e');
          expect(e.toString(), anyOf(contains('409'), contains('500')));
        }
      });

      test('❌ Regular user should NOT create kanji', () async {
        await testHelper.loginAndGetToken();

        final testKanji = {
          'character': '禁',
          'onyomi': ['キン'],
          'kunyomi': ['いまし.める'],
          'meanings': ['forbid', 'prohibit'],
          'strokeCount': 13,
        };

        try {
          await apiClient.post('/kanji', data: testKanji);
          fail('Regular user should NOT be able to create kanji');
        } catch (e) {
          print('✅ Correctly blocked regular user from creating kanji: $e');
          // Backend may return 401 (no token) or 403 (insufficient permissions)
          expect(e.toString(), anyOf(contains('401'), contains('403')));
        }
      });
    });

    group('Kanji Create → Dictionary Flow Tests', () {
      testWidgets(
        '✅ Created kanji should appear in dictionary [SKIPPED - Requires emulator]',
        (WidgetTester tester) async {
          await testHelper.loginAsAdmin();

          // Reset GetIt and reinitialize for widget test
          await GetIt.instance.reset();
          await di.init();

          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Click add button
          final addButton = find.byIcon(Icons.add);
          await tester.tap(addButton);
          await tester.pumpAndSettle();

          // Fill form
          final fields = find.byType(TextField);
          await tester.enterText(fields.at(0), '験'); // character
          await tester.enterText(fields.at(1), 'ケン, ゲン'); // onyomi
          await tester.enterText(fields.at(2), 'しる.す'); // kunyomi
          await tester.enterText(
            fields.at(3),
            'verification, test',
          ); // meanings
          await tester.enterText(fields.at(4), '18'); // stroke count

          await tester.pumpAndSettle();

          // Select JLPT level
          final jlptDropdown = find.byType(DropdownButtonFormField<String?>);
          await tester.tap(jlptDropdown.first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('N3').last);
          await tester.pumpAndSettle();

          // Submit
          final createButton = find.text('Create');
          await tester.tap(createButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Should navigate back to dictionary
          expect(find.text('Kanji Dictionary'), findsOneWidget);

          // Search for the created kanji
          expect(find.text('験'), findsWidgets);
        },
        skip: true,
      ); // Requires emulator/device
    });

    group('Kanji Detail Tests', () {
      test('✅ Load kanji by ID should return details', () async {
        await testHelper.loginAndGetToken();

        // Get first kanji from list
        final listResponse = await apiClient.get('/kanji?limit=1');
        final wrappedData = listResponse.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        List<dynamic> kanjiList = [];
        if (actualData is Map<String, dynamic>) {
          kanjiList = (actualData['data'] as List?) ?? [];
        } else if (actualData is List) {
          kanjiList = actualData;
        }

        expect(kanjiList.length, greaterThan(0));

        final firstKanji = kanjiList.first;
        final kanjiId = firstKanji['id'];

        // Load detail
        final detailResponse = await apiClient.get('/kanji/$kanjiId');
        print('📥 Kanji Detail Response: ${detailResponse.data}');

        final detailWrapped = detailResponse.data as Map<String, dynamic>;
        final kanjiDetail = detailWrapped['data'];

        expect(kanjiDetail['id'], equals(kanjiId));
        expect(kanjiDetail['character'], isNotNull);
        // Backend returns 'meanings' as String, app parses to List
        expect(kanjiDetail['meanings'], isNotNull);

        print('✅ Kanji detail loaded: ${kanjiDetail['character']}');
      });

      blocTest<KanjiBloc, KanjiState>(
        '✅ Load kanji by ID should emit KanjiDetailLoaded',
        build: () => di.sl<KanjiBloc>(),
        act: (bloc) async {
          // Get a kanji ID first
          final listResponse = await apiClient.get('/kanji?limit=1');
          final wrappedData = listResponse.data as Map<String, dynamic>;
          final actualData = wrappedData['data'];

          List<dynamic> kanjiList = [];
          if (actualData is Map<String, dynamic>) {
            kanjiList = (actualData['data'] as List?) ?? [];
          } else if (actualData is List) {
            kanjiList = actualData;
          }

          final firstKanji = kanjiList.first;
          bloc.add(LoadKanjiByIdEvent(firstKanji['id']));
        },
        expect: () => [isA<KanjiLoading>(), isA<KanjiDetailLoaded>()],
        wait: const Duration(seconds: 5),
      );
    });

    group('Kanji Edit Tests (Admin Only)', () {
      test('✅ Admin should be able to update kanji', () async {
        await testHelper.loginAsAdmin();

        // Create a test kanji first
        final testKanji = {
          'character': '編',
          'onyomi': ['ヘン'],
          'kunyomi': ['あ.む'],
          'meanings': ['compilation', 'knit', 'editing'],
          'strokeCount': 15,
          'jlptLevel': 'N2',
        };

        final createResponse = await apiClient.post('/kanji', data: testKanji);
        final createWrapped = createResponse.data as Map<String, dynamic>;
        final createdKanji = createWrapped['data'];
        final kanjiId = createdKanji['id'];

        print('✅ Created test kanji with ID: $kanjiId');

        // Update it
        final updateData = {
          'character': '編',
          'onyomi': ['ヘン'],
          'kunyomi': ['あ.む', 'つづ.る'],
          'meanings': ['compilation', 'knit', 'editing', 'weave'],
          'strokeCount': 15,
          'jlptLevel': 'N1', // Changed from N2
        };

        try {
          final updateResponse = await apiClient.put(
            '/kanji/$kanjiId',
            data: updateData,
          );
          print('📥 Update Response: ${updateResponse.data}');

          expect(updateResponse.statusCode, equals(200));

          final updateWrapped = updateResponse.data as Map<String, dynamic>;
          final updatedKanji = updateWrapped['data'];

          // Backend returns 'jlpt' as int (1 for N1, 2 for N2, etc.)
          expect(updatedKanji['jlpt'], equals(1)); // N1 = 1
          // Backend returns 'meanings' as comma-separated string
          final meaningsStr = updatedKanji['meanings'] as String;
          expect(meaningsStr.split(',').length, equals(4));

          print('✅ Kanji updated successfully');
        } finally {
          // Cleanup
          await apiClient.delete('/kanji/$kanjiId');
          print('🗑️ Cleaned up test kanji');
        }
      });

      test('❌ Regular user should NOT update kanji', () async {
        await testHelper.loginAndGetToken();

        // Get an existing kanji
        final listResponse = await apiClient.get('/kanji?limit=1');
        final wrappedData = listResponse.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        List<dynamic> kanjiList = [];
        if (actualData is Map<String, dynamic>) {
          kanjiList = (actualData['data'] as List?) ?? [];
        } else if (actualData is List) {
          kanjiList = actualData;
        }

        final firstKanji = kanjiList.first;

        try {
          await apiClient.put(
            '/kanji/${firstKanji['id']}',
            data: {
              'meanings': ['unauthorized change'],
            },
          );
          fail('Regular user should NOT be able to update kanji');
        } catch (e) {
          print('✅ Correctly blocked regular user from updating kanji: $e');
          expect(e.toString(), anyOf(contains('401'), contains('403')));
        }
      });
    });

    group('Kanji Delete Tests (Admin Only)', () {
      test('✅ Admin should be able to delete kanji', () async {
        await testHelper.loginAsAdmin();

        // Create a test kanji first
        final testKanji = {
          'character': '削',
          'onyomi': ['サク'],
          'kunyomi': ['けず.る'],
          'meanings': ['delete', 'plane', 'sharpen'],
          'strokeCount': 9,
        };

        final createResponse = await apiClient.post('/kanji', data: testKanji);
        final createWrapped = createResponse.data as Map<String, dynamic>;
        final createdKanji = createWrapped['data'];
        final kanjiId = createdKanji['id'];

        print('✅ Created test kanji for deletion with ID: $kanjiId');

        // Delete it
        final deleteResponse = await apiClient.delete('/kanji/$kanjiId');
        expect(deleteResponse.statusCode, equals(200));

        print('✅ Kanji deleted successfully');

        // Verify it's gone
        try {
          await apiClient.get('/kanji/$kanjiId');
          fail('Kanji should be deleted');
        } catch (e) {
          print('✅ Confirmed kanji is deleted');
          expect(e.toString(), contains('404'));
        }
      });

      test('❌ Regular user should NOT delete kanji', () async {
        await testHelper.loginAndGetToken();

        // Get an existing kanji
        final listResponse = await apiClient.get('/kanji?limit=1');
        final wrappedData = listResponse.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        List<dynamic> kanjiList = [];
        if (actualData is Map<String, dynamic>) {
          kanjiList = (actualData['data'] as List?) ?? [];
        } else if (actualData is List) {
          kanjiList = actualData;
        }

        final firstKanji = kanjiList.first;

        try {
          await apiClient.delete('/kanji/${firstKanji['id']}');
          fail('Regular user should NOT be able to delete kanji');
        } catch (e) {
          print('✅ Correctly blocked regular user from deleting kanji: $e');
          expect(e.toString(), anyOf(contains('401'), contains('403')));
        }
      });
    });
  });
}
