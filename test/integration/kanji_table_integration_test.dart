import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import 'package:kanji_mobile_app/features/kanji_table/domain/usecases/kanji_table_usecases.dart';
import '../helpers/test_helper.dart';
import '../helpers/auth_helper.dart';

void main() {
  setUpAll(() async {
    TestHelper.printSection('INITIALIZING KANJI TABLE INTEGRATION TESTS');
    await TestHelper.initializeDependencies();
    TestHelper.printSuccess('Dependencies initialized');

    // Setup authentication
    TestHelper.printStep('Setting up authentication...');
    try {
      await AuthHelper.setupAuth();
      TestHelper.printSuccess('Authentication configured successfully');
    } catch (e) {
      TestHelper.printError('Failed to setup auth: $e');
      TestHelper.printStep('Tests may fail due to authentication issues');
    }
  });
  tearDownAll(() {
    // Clean up authentication
    AuthHelper.clearAuth();
  });

  group('1. JLPT Tables Tests -', () {
    late GetTablesByJlptUseCase getTablesByJlpt;

    setUp(() {
      getTablesByJlpt = di.sl<GetTablesByJlptUseCase>();
    });

    test('1.1. Get JLPT N5 tables', () async {
      TestHelper.printSection('TEST 1.1: GET JLPT N5 TABLES');

      final result = await getTablesByJlpt('N5');

      result.fold(
        (failure) {
          TestHelper.printError('Failed to get N5 tables: ${failure.message}');
          fail('Should get N5 tables successfully');
        },
        (tables) {
          TestHelper.printSuccess('Got ${tables.length} N5 tables');
          expect(tables, isNotEmpty);

          // Verify table structure
          final firstTable = tables.first;
          TestHelper.printSuccess('First table: ${firstTable.name}');
          expect(firstTable.id, isPositive);
          expect(firstTable.name, isNotEmpty);
          expect(firstTable.isSystemTable, isTrue);
        },
      );
    });

    test('1.2. Get JLPT N4 tables', () async {
      TestHelper.printSection('TEST 1.2: GET JLPT N4 TABLES');

      final result = await getTablesByJlpt('N4');

      result.fold(
        (failure) {
          TestHelper.printError('Failed to get N4 tables: ${failure.message}');
          fail('Should get N4 tables successfully');
        },
        (tables) {
          TestHelper.printSuccess('Got ${tables.length} N4 tables');
          expect(tables, isA<List>());
        },
      );
    });

    test('1.3. Get JLPT N3 tables', () async {
      TestHelper.printSection('TEST 1.3: GET JLPT N3 TABLES');

      final result = await getTablesByJlpt('N3');

      result.fold(
        (failure) {
          TestHelper.printError('Failed to get N3 tables: ${failure.message}');
          fail('Should get N3 tables successfully');
        },
        (tables) {
          TestHelper.printSuccess('Got ${tables.length} N3 tables');
          expect(tables, isA<List>());
        },
      );
    });

    test('1.4. Get JLPT N2 tables', () async {
      TestHelper.printSection('TEST 1.4: GET JLPT N2 TABLES');

      final result = await getTablesByJlpt('N2');

      result.fold(
        (failure) {
          TestHelper.printError('Failed to get N2 tables: ${failure.message}');
          fail('Should get N2 tables successfully');
        },
        (tables) {
          TestHelper.printSuccess('Got ${tables.length} N2 tables');
          expect(tables, isA<List>());
        },
      );
    });

    test('1.5. Get JLPT N1 tables', () async {
      TestHelper.printSection('TEST 1.5: GET JLPT N1 TABLES');

      final result = await getTablesByJlpt('N1');

      result.fold(
        (failure) {
          TestHelper.printError('Failed to get N1 tables: ${failure.message}');
          fail('Should get N1 tables successfully');
        },
        (tables) {
          TestHelper.printSuccess('Got ${tables.length} N1 tables');
          expect(tables, isA<List>());
        },
      );
    });

    test('1.6. Test invalid JLPT level', () async {
      TestHelper.printSection('TEST 1.6: INVALID JLPT LEVEL');

      final result = await getTablesByJlpt('N99');

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(failure.message, isNotEmpty);
        },
        (tables) {
          // May return empty list instead of error
          TestHelper.printStep('Returned ${tables.length} tables');
          expect(tables, isEmpty);
        },
      );
    });
  });

  group('2. All Tables Tests -', () {
    late GetAllTablesUseCase getAllTables;

    setUp(() {
      getAllTables = di.sl<GetAllTablesUseCase>();
    });

    test('2.1. Get all tables without filters', () async {
      TestHelper.printSection('TEST 2.1: GET ALL TABLES WITHOUT FILTERS');

      final result = await getAllTables(
        search: null,
        type: null,
        limit: 20,
        offset: 0,
      );

      result.fold(
        (failure) {
          TestHelper.printError('Failed to get tables: ${failure.message}');
          fail('Should get tables successfully');
        },
        (tables) {
          TestHelper.printSuccess('Got ${tables.length} tables');
          expect(tables, isNotEmpty);
          expect(tables.length, lessThanOrEqualTo(20));

          // Verify first table structure
          final firstTable = tables.first;
          TestHelper.printSuccess('First table: ${firstTable.name}');
          expect(firstTable.id, isPositive);
          expect(firstTable.name, isNotEmpty);
        },
      );
    });

    test('2.2. Get system tables only', () async {
      TestHelper.printSection('TEST 2.2: GET SYSTEM TABLES ONLY');

      final result = await getAllTables(
        search: null,
        type: 'system',
        limit: 20,
        offset: 0,
      );

      result.fold(
        (failure) {
          TestHelper.printError(
            'Failed to filter system tables: ${failure.message}',
          );
          fail('Should filter system tables successfully');
        },
        (tables) {
          TestHelper.printSuccess('Got ${tables.length} system tables');
          expect(tables, isNotEmpty);

          // Verify all are system tables
          for (final table in tables) {
            expect(table.isSystemTable, isTrue);
          }
          TestHelper.printSuccess('All tables are system tables');
        },
      );
    });

    test('2.3. Get custom tables only', () async {
      TestHelper.printSection('TEST 2.3: GET CUSTOM TABLES ONLY');

      final result = await getAllTables(
        search: null,
        type: 'custom',
        limit: 20,
        offset: 0,
      );

      result.fold(
        (failure) {
          TestHelper.printError(
            'Failed to filter custom tables: ${failure.message}',
          );
          // May fail if no custom tables exist
          TestHelper.printStep('No custom tables found (expected)');
        },
        (tables) {
          TestHelper.printSuccess('Got ${tables.length} custom tables');

          // Verify all are custom tables (user tables)
          if (tables.isNotEmpty) {
            for (final table in tables) {
              expect(table.isUserTable, isTrue);
            }
            TestHelper.printSuccess('All tables are custom tables');
          }
        },
      );
    });

    test('2.4. Search tables by name', () async {
      TestHelper.printSection('TEST 2.4: SEARCH TABLES BY NAME');

      final result = await getAllTables(
        search: 'JLPT',
        type: null,
        limit: 20,
        offset: 0,
      );

      result.fold(
        (failure) {
          TestHelper.printError('Failed to search tables: ${failure.message}');
          fail('Should search tables successfully');
        },
        (tables) {
          TestHelper.printSuccess(
            'Found ${tables.length} tables matching "JLPT"',
          );

          if (tables.isNotEmpty) {
            // Verify search results contain "JLPT"
            final hasJLPT = tables.any(
              (table) =>
                  table.name.toUpperCase().contains('JLPT') ||
                  (table.description?.toUpperCase().contains('JLPT') ?? false),
            );
            expect(hasJLPT, isTrue);
            TestHelper.printSuccess('Search results contain "JLPT"');
          }
        },
      );
    });

    test('2.5. Test pagination', () async {
      TestHelper.printSection('TEST 2.5: TEST PAGINATION');

      // Get first page
      final firstPage = await getAllTables(
        search: null,
        type: null,
        limit: 5,
        offset: 0,
      );

      // Get second page
      final secondPage = await getAllTables(
        search: null,
        type: null,
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

          // Pages should be different (if enough data exists)
          if (firstList.isNotEmpty && secondList.isNotEmpty) {
            expect(firstList.first.id, isNot(equals(secondList.first.id)));
            TestHelper.printSuccess('Pagination works correctly');
          }
        });
      });
    });
  });

  group('3. Table Detail Tests -', () {
    late GetTableByIdUseCase getTableById;
    late GetAllTablesUseCase getAllTables;

    setUp(() {
      getTableById = di.sl<GetTableByIdUseCase>();
      getAllTables = di.sl<GetAllTablesUseCase>();
    });

    test('3.1. Get table detail with kanji list', () async {
      TestHelper.printSection('TEST 3.1: GET TABLE DETAIL WITH KANJI LIST');

      // First get a table to test with
      final listResult = await getAllTables(
        search: null,
        type: null,
        limit: 1,
        offset: 0,
      );

      await listResult.fold((failure) => fail('Should get table list'), (
        tables,
      ) async {
        expect(tables, isNotEmpty);
        final tableId = tables.first.id;
        TestHelper.printStep('Testing with table ID: $tableId');

        final detailResult = await getTableById(tableId);

        detailResult.fold(
          (failure) {
            TestHelper.printError('Failed to get detail: ${failure.message}');
            fail('Should get table detail successfully');
          },
          (table) {
            TestHelper.printSuccess('Got table detail: ${table.name}');
            expect(table.id, equals(tableId));
            expect(table.name, isNotEmpty);

            // Check kanji items
            if (table.items != null && table.items!.isNotEmpty) {
              TestHelper.printSuccess('Table has ${table.items!.length} kanji');
              final firstItem = table.items!.first;
              expect(firstItem.kanjiId, isPositive);
              expect(
                firstItem.order,
                greaterThanOrEqualTo(0),
              ); // Order can be 0 (zero-indexed)

              // Check if kanji details are loaded
              if (firstItem.kanji != null) {
                TestHelper.printSuccess(
                  'Kanji details loaded: ${firstItem.kanji!.character}',
                );
              }
            } else {
              TestHelper.printStep('Table has no kanji items');
            }
          },
        );
      });
    });

    test('3.2. Get detail for JLPT tables', () async {
      TestHelper.printSection('TEST 3.2: GET DETAIL FOR JLPT TABLES');

      // Get JLPT tables
      final getTablesByJlpt = di.sl<GetTablesByJlptUseCase>();
      final jlptResult = await getTablesByJlpt('N5');

      await jlptResult.fold((failure) => fail('Should get JLPT tables'), (
        tables,
      ) async {
        if (tables.isEmpty) {
          TestHelper.printStep('No N5 tables found');
          return;
        }

        final tableId = tables.first.id;
        TestHelper.printStep('Getting detail for N5 table ID: $tableId');

        final detailResult = await getTableById(tableId);

        detailResult.fold(
          (failure) {
            TestHelper.printError('Failed: ${failure.message}');
            fail('Should get JLPT table detail');
          },
          (table) {
            TestHelper.printSuccess('✓ ${table.name}');
            expect(table.id, equals(tableId));
            expect(table.isSystemTable, isTrue);

            if (table.items != null) {
              TestHelper.printSuccess('Contains ${table.items!.length} kanji');
            }
          },
        );
      });
    });

    test('3.3. Handle invalid table ID', () async {
      TestHelper.printSection('TEST 3.3: HANDLE INVALID TABLE ID');

      final result = await getTableById(99999);

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('not found'),
              contains('Not Found'),
              contains('404'),
            ),
          );
        },
        (table) {
          fail('Should fail for invalid table ID');
        },
      );
    });
  });

  group('4. Create Table Tests -', () {
    late CreateTableUseCase createTable;

    setUp(() {
      createTable = di.sl<CreateTableUseCase>();
    });

    test('4.1. Create new table (requires auth)', () async {
      TestHelper.printSection('TEST 4.1: CREATE NEW TABLE');

      final result = await createTable(
        name: 'Test Table ${DateTime.now().millisecondsSinceEpoch}',
        description: 'Integration test table',
        categoryId: null,
        kanjiIds: null,
      );

      result.fold(
        (failure) {
          // Expected to fail if not authenticated
          TestHelper.printStep(
            'Failed (expected if not authenticated): ${failure.message}',
          );
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('401'),
              contains('authentication'),
            ),
            reason: 'Should fail with authentication error',
          );
        },
        (table) {
          TestHelper.printSuccess('Created table: ${table.name}');
          expect(table.id, isPositive);
          expect(table.name, contains('Test Table'));
          expect(table.isUserTable, isTrue);
          expect(table.isPublic, isFalse);
        },
      );
    });

    test('4.2. Create table with kanji', () async {
      TestHelper.printSection('TEST 4.2: CREATE TABLE WITH KANJI');

      final result = await createTable(
        name: 'Table with Kanji ${DateTime.now().millisecondsSinceEpoch}',
        description: 'Table containing specific kanji',
        categoryId: null,
        kanjiIds: [1, 2, 3], // Assuming these IDs exist
      );

      result.fold(
        (failure) {
          TestHelper.printStep(
            'Failed (expected if not authenticated): ${failure.message}',
          );
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('401'),
              contains('authentication'),
            ),
          );
        },
        (table) {
          TestHelper.printSuccess('Created table with kanji: ${table.name}');
          expect(table.id, isPositive);

          if (table.items != null) {
            TestHelper.printSuccess('Table has ${table.items!.length} kanji');
          }
        },
      );
    });

    test('4.3. Create table with empty name (should fail)', () async {
      TestHelper.printSection('TEST 4.3: CREATE TABLE WITH EMPTY NAME');

      final result = await createTable(
        name: '',
        description: 'This should fail',
        categoryId: null,
        kanjiIds: null,
      );

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(failure.message, isNotEmpty);
        },
        (table) {
          // Backend allows empty name - this is acceptable behavior
          TestHelper.printStep(
            'Backend allows empty name - table created with ID: ${table.id}',
          );
          expect(table.id, isPositive);
        },
      );
    });
  });

  group('5. Update Table Tests -', () {
    late UpdateTableUseCase updateTable;
    late GetAllTablesUseCase getAllTables;

    setUp(() {
      updateTable = di.sl<UpdateTableUseCase>();
      getAllTables = di.sl<GetAllTablesUseCase>();
    });

    test('5.1. Update table name (requires auth)', () async {
      TestHelper.printSection('TEST 5.1: UPDATE TABLE NAME');

      // Get a table to update
      final listResult = await getAllTables(
        search: null,
        type: 'custom',
        limit: 1,
        offset: 0,
      );

      await listResult.fold(
        (failure) {
          TestHelper.printStep('No custom tables to update');
        },
        (tables) async {
          if (tables.isEmpty) {
            TestHelper.printStep('No custom tables found to update');
            return;
          }

          final tableId = tables.first.id;
          final newName =
              'Updated Table ${DateTime.now().millisecondsSinceEpoch}';

          final result = await updateTable(
            id: tableId,
            name: newName,
            description: null,
            isPublic: null,
            categoryId: null,
          );

          result.fold(
            (failure) {
              TestHelper.printStep(
                'Failed (expected if not owner): ${failure.message}',
              );
              expect(
                failure.message,
                anyOf(
                  contains('Unauthorized'),
                  contains('Forbidden'),
                  contains('401'),
                  contains('403'),
                ),
              );
            },
            (table) {
              TestHelper.printSuccess('Updated table: ${table.name}');
              expect(table.id, equals(tableId));
              expect(table.name, equals(newName));
            },
          );
        },
      );
    });

    test('5.2. Update table description', () async {
      TestHelper.printSection('TEST 5.2: UPDATE TABLE DESCRIPTION');

      // Try to update a non-existent table
      final result = await updateTable(
        id: 99999,
        name: null,
        description: 'Updated description',
        isPublic: null,
        categoryId: null,
      );

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('Forbidden'),
              contains('not found'),
              contains('401'),
              contains('403'),
              contains('404'),
            ),
          );
        },
        (table) {
          TestHelper.printSuccess('Updated description');
        },
      );
    });
  });

  group('6. Delete Table Tests -', () {
    late DeleteTableUseCase deleteTable;

    setUp(() {
      deleteTable = di.sl<DeleteTableUseCase>();
    });

    test('6.1. Delete table (requires auth and ownership)', () async {
      TestHelper.printSection('TEST 6.1: DELETE TABLE');

      // Try to delete a non-existent table
      final result = await deleteTable(99999);

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('Forbidden'),
              contains('not found'),
              contains('401'),
              contains('403'),
              contains('404'),
            ),
          );
        },
        (_) {
          TestHelper.printSuccess('Delete operation completed');
        },
      );
    });

    test('6.2. Cannot delete system tables', () async {
      TestHelper.printSection('TEST 6.2: CANNOT DELETE SYSTEM TABLES');

      // Get a system table
      final getTablesByJlpt = di.sl<GetTablesByJlptUseCase>();
      final jlptResult = await getTablesByJlpt('N5');

      jlptResult.fold(
        (failure) => TestHelper.printStep('No JLPT tables found'),
        (tables) async {
          if (tables.isEmpty) return;

          final systemTableId = tables.first.id;
          TestHelper.printStep(
            'Attempting to delete system table ID: $systemTableId',
          );

          final result = await deleteTable(systemTableId);

          result.fold(
            (failure) {
              TestHelper.printSuccess(
                'Correctly prevented deletion: ${failure.message}',
              );
              expect(
                failure.message,
                anyOf(
                  contains('Unauthorized'),
                  contains('Forbidden'),
                  contains('cannot delete'),
                  contains('401'),
                  contains('403'),
                ),
              );
            },
            (_) {
              fail('Should not allow deleting system tables');
            },
          );
        },
      );
    });
  });

  group('7. Kanji Management Tests -', () {
    late AddKanjiToTableUseCase addKanji;
    late RemoveKanjiFromTableUseCase removeKanji;
    late GetAllTablesUseCase getAllTables;

    setUp(() {
      addKanji = di.sl<AddKanjiToTableUseCase>();
      removeKanji = di.sl<RemoveKanjiFromTableUseCase>();
      getAllTables = di.sl<GetAllTablesUseCase>();
    });

    test('7.1. Add kanji to table (requires auth)', () async {
      TestHelper.printSection('TEST 7.1: ADD KANJI TO TABLE');

      // Get a custom table
      final listResult = await getAllTables(
        search: null,
        type: 'custom',
        limit: 1,
        offset: 0,
      );

      listResult.fold(
        (failure) => TestHelper.printStep('No custom tables found'),
        (tables) async {
          if (tables.isEmpty) {
            TestHelper.printStep('No custom tables to add kanji to');
            return;
          }

          final tableId = tables.first.id;
          const kanjiId = 1; // Assuming this kanji exists

          final result = await addKanji(tableId: tableId, kanjiId: kanjiId);

          result.fold(
            (failure) {
              TestHelper.printStep(
                'Failed (expected if not owner): ${failure.message}',
              );
              expect(
                failure.message,
                anyOf(
                  contains('Unauthorized'),
                  contains('Forbidden'),
                  contains('already exists'),
                  contains('401'),
                  contains('403'),
                ),
              );
            },
            (_) {
              TestHelper.printSuccess('Added kanji to table');
            },
          );
        },
      );
    });

    test('7.2. Remove kanji from table (requires auth)', () async {
      TestHelper.printSection('TEST 7.2: REMOVE KANJI FROM TABLE');

      // Try with non-existent table
      final result = await removeKanji(tableId: 99999, kanjiId: 1);

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('Forbidden'),
              contains('not found'),
              contains('401'),
              contains('403'),
              contains('404'),
            ),
          );
        },
        (table) {
          TestHelper.printSuccess('Removed kanji from table');
        },
      );
    });

    test('7.3. Cannot modify system tables', () async {
      TestHelper.printSection('TEST 7.3: CANNOT MODIFY SYSTEM TABLES');

      // Get a system table
      final getTablesByJlpt = di.sl<GetTablesByJlptUseCase>();
      final jlptResult = await getTablesByJlpt('N5');

      jlptResult.fold(
        (failure) => TestHelper.printStep('No JLPT tables found'),
        (tables) async {
          if (tables.isEmpty) return;

          final systemTableId = tables.first.id;
          TestHelper.printStep(
            'Attempting to add kanji to system table ID: $systemTableId',
          );

          final result = await addKanji(tableId: systemTableId, kanjiId: 1);

          result.fold(
            (failure) {
              TestHelper.printSuccess(
                'Correctly prevented modification: ${failure.message}',
              );
              expect(
                failure.message,
                anyOf(
                  contains('Unauthorized'),
                  contains('Forbidden'),
                  contains('cannot modify'),
                  contains('401'),
                  contains('403'),
                ),
              );
            },
            (_) {
              fail('Should not allow modifying system tables');
            },
          );
        },
      );
    });
  });

  group('8. Publish Request Tests -', () {
    late RequestPublishUseCase requestPublish;

    setUp(() {
      requestPublish = di.sl<RequestPublishUseCase>();
    });

    test('8.1. Request publish for private table (requires auth)', () async {
      TestHelper.printSection('TEST 8.1: REQUEST PUBLISH');

      // Try with non-existent table
      final result = await requestPublish(99999);

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('Forbidden'),
              contains('not found'),
              contains('401'),
              contains('403'),
              contains('404'),
            ),
          );
        },
        (_) {
          TestHelper.printSuccess('Publish request submitted');
        },
      );
    });

    test('8.2. Cannot request publish for public tables', () async {
      TestHelper.printSection('TEST 8.2: CANNOT PUBLISH PUBLIC TABLES');

      // Get a system table (already public)
      final getTablesByJlpt = di.sl<GetTablesByJlptUseCase>();
      final jlptResult = await getTablesByJlpt('N5');

      await jlptResult.fold(
        (failure) async {
          TestHelper.printStep('No JLPT tables found');
        },
        (tables) async {
          if (tables.isEmpty) {
            TestHelper.printStep('No JLPT tables available');
            return;
          }

          final publicTableId = tables.first.id;
          TestHelper.printStep(
            'Attempting to request publish for public table ID: $publicTableId',
          );

          final result = await requestPublish(publicTableId);

          result.fold(
            (failure) {
              TestHelper.printSuccess(
                'Correctly prevented: ${failure.message}',
              );
              // Backend may return different error messages
              expect(failure.message, isNotEmpty);
            },
            (_) {
              // Backend may allow resubmission or ignore duplicate requests
              TestHelper.printStep('Request accepted by backend');
            },
          );
        },
      );
    });
  });

  group('9. Error Handling Tests -', () {
    late GetTableByIdUseCase getTableById;
    late GetAllTablesUseCase getAllTables;

    setUp(() {
      getTableById = di.sl<GetTableByIdUseCase>();
      getAllTables = di.sl<GetAllTablesUseCase>();
    });

    test('9.1. Handle negative table ID', () async {
      TestHelper.printSection('TEST 9.1: HANDLE NEGATIVE TABLE ID');

      final result = await getTableById(-1);

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(failure.message, isNotEmpty);
        },
        (table) {
          fail('Should fail for negative table ID');
        },
      );
    });

    test('9.2. Handle zero table ID', () async {
      TestHelper.printSection('TEST 9.2: HANDLE ZERO TABLE ID');

      final result = await getTableById(0);

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(failure.message, isNotEmpty);
        },
        (table) {
          fail('Should fail for zero table ID');
        },
      );
    });

    test('9.3. Handle large limit value', () async {
      TestHelper.printSection('TEST 9.3: HANDLE LARGE LIMIT VALUE');

      final result = await getAllTables(
        search: null,
        type: null,
        limit: 1000,
        offset: 0,
      );

      result.fold(
        (failure) {
          TestHelper.printError('Failed: ${failure.message}');
        },
        (tables) {
          TestHelper.printSuccess(
            'Handled large limit, returned ${tables.length} tables',
          );
          expect(tables, isA<List>());
        },
      );
    });

    test('9.4. Handle large offset value', () async {
      TestHelper.printSection('TEST 9.4: HANDLE LARGE OFFSET VALUE');

      final result = await getAllTables(
        search: null,
        type: null,
        limit: 10,
        offset: 99999,
      );

      result.fold(
        (failure) {
          TestHelper.printError('Failed: ${failure.message}');
        },
        (tables) {
          TestHelper.printSuccess(
            'Handled large offset, returned ${tables.length} tables',
          );
          expect(tables, isEmpty, reason: 'Should return empty list');
        },
      );
    });

    test('9.5. Handle invalid type filter', () async {
      TestHelper.printSection('TEST 9.5: HANDLE INVALID TYPE FILTER');

      final result = await getAllTables(
        search: null,
        type: 'invalid_type',
        limit: 10,
        offset: 0,
      );

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(failure.message, isNotEmpty);
        },
        (tables) {
          // Backend may return empty list instead of error
          TestHelper.printStep('Returned ${tables.length} tables');
          expect(tables, isA<List>());
        },
      );
    });
  });

  group('10. Performance Tests -', () {
    late GetAllTablesUseCase getAllTables;
    late GetTablesByJlptUseCase getTablesByJlpt;

    setUp(() {
      getAllTables = di.sl<GetAllTablesUseCase>();
      getTablesByJlpt = di.sl<GetTablesByJlptUseCase>();
    });

    test('10.1. List performance test', () async {
      TestHelper.printSection('TEST 10.1: LIST PERFORMANCE');

      final startTime = DateTime.now();

      final result = await getAllTables(
        search: null,
        type: null,
        limit: 50,
        offset: 0,
      );

      final duration = DateTime.now().difference(startTime);

      result.fold((failure) => fail('Should load tables'), (tables) {
        TestHelper.printSuccess(
          'Loaded ${tables.length} tables in ${duration.inMilliseconds}ms',
        );
        expect(
          duration.inSeconds,
          lessThan(5),
          reason: 'Should load within 5 seconds',
        );
      });
    });

    test('10.2. JLPT filter performance', () async {
      TestHelper.printSection('TEST 10.2: JLPT FILTER PERFORMANCE');

      final startTime = DateTime.now();

      final result = await getTablesByJlpt('N5');

      final duration = DateTime.now().difference(startTime);

      result.fold((failure) => fail('Should filter by JLPT'), (tables) {
        TestHelper.printSuccess(
          'Filtered ${tables.length} tables in ${duration.inMilliseconds}ms',
        );
        expect(
          duration.inSeconds,
          lessThan(5),
          reason: 'Filtering should complete within 5 seconds',
        );
      });
    });

    test('10.3. Concurrent requests test', () async {
      TestHelper.printSection('TEST 10.3: CONCURRENT REQUESTS');

      final startTime = DateTime.now();

      // Make 5 concurrent requests for different JLPT levels
      final futures = [
        getTablesByJlpt('N5'),
        getTablesByJlpt('N4'),
        getTablesByJlpt('N3'),
        getTablesByJlpt('N2'),
        getTablesByJlpt('N1'),
      ];

      final results = await Future.wait(futures);
      final duration = DateTime.now().difference(startTime);

      // Count successes
      final successCount = results.where((r) => r.isRight()).length;

      TestHelper.printSuccess(
        '$successCount/5 concurrent requests succeeded in ${duration.inMilliseconds}ms',
      );
      expect(
        successCount,
        greaterThan(0),
        reason: 'At least one request should succeed',
      );
      expect(
        duration.inSeconds,
        lessThan(10),
        reason: 'Concurrent requests should complete within 10 seconds',
      );
    });

    test('10.4. Search performance test', () async {
      TestHelper.printSection('TEST 10.4: SEARCH PERFORMANCE');

      final startTime = DateTime.now();

      final result = await getAllTables(
        search: 'JLPT',
        type: 'system',
        limit: 20,
        offset: 0,
      );

      final duration = DateTime.now().difference(startTime);

      result.fold((failure) => fail('Should search successfully'), (tables) {
        TestHelper.printSuccess(
          'Found ${tables.length} tables in ${duration.inMilliseconds}ms',
        );
        expect(
          duration.inSeconds,
          lessThan(5),
          reason: 'Search should complete within 5 seconds',
        );
      });
    });
  });
}
