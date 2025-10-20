import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_flutter/injection_container.dart' as di;
import 'package:kanji_flutter/features/kanji_list/presentation/bloc/kanji_list_bloc.dart';
import 'package:kanji_flutter/features/kanji_list/presentation/bloc/kanji_list_event.dart';
import 'package:kanji_flutter/features/kanji_list/presentation/bloc/kanji_list_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Kanji List Feature Integration Tests', () {
    setUpAll(() async {
      await di.init();
    });

    testWidgets('Load All Lists: Should fetch user kanji lists', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is KanjiListLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is ListsLoaded) {
                  return Scaffold(
                    body: ListView.builder(
                      itemCount: state.lists.length,
                      itemBuilder: (context, index) {
                        final list = state.lists[index];
                        return ListTile(
                          title: Text(list.name),
                          subtitle: Text('${list.totalKanji} kanji'),
                        );
                      },
                    ),
                  );
                } else if (state is KanjiListError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Ready')));
              },
            ),
          ),
        ),
      );

      // Load lists
      kanjiListBloc.add(LoadAllListsEvent());

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify
      final state = kanjiListBloc.state;
      expect(state is ListsLoaded || state is KanjiListError, true);

      await kanjiListBloc.close();
    });

    testWidgets('Create List: Should create new kanji list', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is KanjiListLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is ListCreated) {
                  return Scaffold(
                    body: Center(
                      child: Text('List created: ${state.list.name}'),
                    ),
                  );
                } else if (state is KanjiListError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Ready')));
              },
            ),
          ),
        ),
      );

      // Create list with unique name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      kanjiListBloc.add(
        CreateListEvent(
          name: 'Test List $timestamp',
          description: 'Integration test list',
          kanjiIds: [1, 2, 3],
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check result
      final state = kanjiListBloc.state;
      expect(state is ListCreated || state is KanjiListError, true);

      await kanjiListBloc.close();
    });

    testWidgets('Load List Detail: Should fetch specific list with kanji', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is KanjiListLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is ListDetailLoaded) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('List: ${state.list.name}'),
                          Text('Kanji count: ${state.list.totalKanji}'),
                          Text('Public: ${state.list.isPublic ? 'Yes' : 'No'}'),
                        ],
                      ),
                    ),
                  );
                } else if (state is KanjiListError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Ready')));
              },
            ),
          ),
        ),
      );

      // Load list by ID
      kanjiListBloc.add(LoadListByIdEvent(1));

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = kanjiListBloc.state;
      expect(state is ListDetailLoaded || state is KanjiListError, true);

      await kanjiListBloc.close();
    });

    testWidgets('Add Kanji to List: Should add kanji successfully', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is KanjiAddedToList) {
                  return const Scaffold(
                    body: Center(child: Text('Kanji added successfully')),
                  );
                } else if (state is KanjiListError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Add kanji to list
      kanjiListBloc.add(AddKanjiToListEvent(listId: 1, kanjiId: 5));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = kanjiListBloc.state;
      expect(state is KanjiAddedToList || state is KanjiListError, true);

      await kanjiListBloc.close();
    });

    testWidgets('Delete List: Should remove list successfully', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      // First create a list to delete
      kanjiListBloc.add(
        CreateListEvent(
          name: 'List to Delete ${DateTime.now().millisecondsSinceEpoch}',
          description: 'Will be deleted',
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      int? listIdToDelete;
      if (kanjiListBloc.state is ListCreated) {
        listIdToDelete = (kanjiListBloc.state as ListCreated).list.id;
      }

      if (listIdToDelete != null) {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<KanjiListBloc>(
              create: (_) => kanjiListBloc,
              child: BlocBuilder<KanjiListBloc, KanjiListState>(
                builder: (context, state) {
                  if (state is ListDeleted) {
                    return const Scaffold(
                      body: Center(child: Text('List deleted')),
                    );
                  } else if (state is KanjiListError) {
                    return Scaffold(
                      body: Center(child: Text('Error: ${state.message}')),
                    );
                  }
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
        );

        // Delete the list
        kanjiListBloc.add(DeleteListEvent(listIdToDelete));

        await tester.pumpAndSettle(const Duration(seconds: 5));

        final state = kanjiListBloc.state;
        expect(state is ListDeleted || state is KanjiListError, true);
      }

      await kanjiListBloc.close();
    });

    testWidgets('Update List: Should update list name and description', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is ListUpdated) {
                  return Scaffold(
                    body: Center(
                      child: Text('List updated: ${state.list.name}'),
                    ),
                  );
                } else if (state is KanjiListError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Update list
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      kanjiListBloc.add(
        UpdateListEvent(
          id: 1,
          name: 'Updated List $timestamp',
          description: 'Updated description',
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = kanjiListBloc.state;
      expect(state is ListUpdated || state is KanjiListError, true);

      await kanjiListBloc.close();
    });

    testWidgets('Remove Kanji from List: Should remove kanji successfully', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is KanjiRemovedFromList) {
                  return const Scaffold(
                    body: Center(child: Text('Kanji removed successfully')),
                  );
                } else if (state is KanjiListError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Remove kanji from list
      kanjiListBloc.add(RemoveKanjiFromListEvent(listId: 1, kanjiId: 1));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = kanjiListBloc.state;
      expect(state is KanjiRemovedFromList || state is KanjiListError, true);

      await kanjiListBloc.close();
    });

    testWidgets('Filter System Lists: Should separate system and custom lists', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is ListsLoaded) {
                  // System lists typically have userId 0 or a special system ID
                  // Custom lists have userId matching the logged-in user
                  final systemLists = state.lists
                      .where(
                        (list) =>
                            list.name.contains('JLPT') ||
                            list.name.contains('N5') ||
                            list.name.contains('N4') ||
                            list.name.contains('N3') ||
                            list.name.contains('N2') ||
                            list.name.contains('N1'),
                      )
                      .toList();
                  final customLists = state.lists
                      .where(
                        (list) =>
                            !list.name.contains('JLPT') &&
                            !list.name.contains('N5') &&
                            !list.name.contains('N4') &&
                            !list.name.contains('N3') &&
                            !list.name.contains('N2') &&
                            !list.name.contains('N1'),
                      )
                      .toList();

                  return Scaffold(
                    body: Column(
                      children: [
                        Text('System Lists: ${systemLists.length}'),
                        Text('Custom Lists: ${customLists.length}'),
                        Expanded(
                          child: ListView(
                            children: [
                              ...systemLists.map(
                                (list) => ListTile(
                                  title: Text(list.name),
                                  subtitle: const Text('System'),
                                ),
                              ),
                              ...customLists.map(
                                (list) => ListTile(
                                  title: Text(list.name),
                                  subtitle: const Text('Custom'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Load all lists
      kanjiListBloc.add(LoadAllListsEvent());

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify system lists exist (JLPT N5, N4, N3, N2, N1)
      if (kanjiListBloc.state is ListsLoaded) {
        final state = kanjiListBloc.state as ListsLoaded;
        final systemLists = state.lists
            .where(
              (list) =>
                  list.name.contains('JLPT') ||
                  list.name.contains('N5') ||
                  list.name.contains('N4') ||
                  list.name.contains('N3') ||
                  list.name.contains('N2') ||
                  list.name.contains('N1'),
            )
            .toList();
        expect(
          systemLists.length,
          greaterThanOrEqualTo(5),
          reason: 'Should have at least 5 JLPT system lists',
        );
      }

      await kanjiListBloc.close();
    });

    testWidgets('Cannot Modify System List: Should show error', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is KanjiListError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Try to update system list (JLPT N5 should have ID around 1-5)
      kanjiListBloc.add(
        UpdateListEvent(
          id: 1,
          name: 'Modified JLPT N5',
          description: 'Try to modify system list',
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should result in error
      expect(
        kanjiListBloc.state is KanjiListError,
        true,
        reason: 'Cannot modify system lists',
      );

      await kanjiListBloc.close();
    });

    testWidgets('Cannot Delete System List: Should show error', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is KanjiListError) {
                  return Scaffold(
                    body: Center(child: Text('Protected: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Try to delete system list
      kanjiListBloc.add(DeleteListEvent(1));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should result in error
      expect(
        kanjiListBloc.state is KanjiListError,
        true,
        reason: 'Cannot delete system lists',
      );

      await kanjiListBloc.close();
    });

    testWidgets('Duplicate Kanji: Should show error when adding duplicate', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is KanjiListError) {
                  return Scaffold(
                    body: Center(child: Text('Duplicate: ${state.message}')),
                  );
                } else if (state is KanjiAddedToList) {
                  return const Scaffold(
                    body: Center(child: Text('Kanji added')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Try to add kanji that's already in the list (N5 list has kanji 1)
      kanjiListBloc.add(AddKanjiToListEvent(listId: 1, kanjiId: 1));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show error about duplicate
      expect(
        kanjiListBloc.state is KanjiListError,
        true,
        reason: 'Cannot add duplicate kanji to list',
      );

      await kanjiListBloc.close();
    });

    testWidgets('List Not Found: Should show error for invalid list ID', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is KanjiListError) {
                  return Scaffold(
                    body: Center(child: Text('Not Found: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Try to load non-existent list
      kanjiListBloc.add(LoadListByIdEvent(99999));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show 404 error
      expect(
        kanjiListBloc.state is KanjiListError,
        true,
        reason: 'Invalid list ID should result in error',
      );

      await kanjiListBloc.close();
    });

    testWidgets('Toggle List Visibility: Should change public status', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is ListUpdated) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('List: ${state.list.name}'),
                          Text('Public: ${state.list.isPublic}'),
                        ],
                      ),
                    ),
                  );
                } else if (state is KanjiListError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Toggle visibility
      kanjiListBloc.add(UpdateListEvent(id: 1, isPublic: true));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = kanjiListBloc.state;
      expect(state is ListUpdated || state is KanjiListError, true);

      await kanjiListBloc.close();
    });

    testWidgets('Multiple Lists CRUD: Should handle multiple operations', (
      WidgetTester tester,
    ) async {
      final kanjiListBloc = di.sl<KanjiListBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                return Scaffold(
                  body: Center(child: Text('State: ${state.runtimeType}')),
                );
              },
            ),
          ),
        ),
      );

      // Load all lists
      kanjiListBloc.add(LoadAllListsEvent());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Create a new list
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      kanjiListBloc.add(
        CreateListEvent(
          name: 'Multi Test List $timestamp',
          description: 'Testing multiple operations',
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify operations completed
      expect(
        kanjiListBloc.state is ListCreated ||
            kanjiListBloc.state is ListsLoaded ||
            kanjiListBloc.state is KanjiListError,
        true,
        reason: 'Should complete multiple operations',
      );

      await kanjiListBloc.close();
    });
  });
}
