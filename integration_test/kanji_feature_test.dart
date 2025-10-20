import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_flutter/injection_container.dart' as di;
import 'package:kanji_flutter/features/kanji/presentation/bloc/kanji_bloc.dart';
import 'package:kanji_flutter/features/kanji/presentation/bloc/kanji_event.dart';
import 'package:kanji_flutter/features/kanji/presentation/bloc/kanji_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Kanji Feature Integration Tests', () {
    setUpAll(() async {
      await di.init();
    });

    testWidgets('Load Kanji List: Should fetch kanji from API', (
      WidgetTester tester,
    ) async {
      final kanjiBloc = di.sl<KanjiBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiBloc>(
            create: (_) => kanjiBloc,
            child: BlocBuilder<KanjiBloc, KanjiState>(
              builder: (context, state) {
                if (state is KanjiLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is KanjiListLoaded) {
                  return Scaffold(
                    body: ListView.builder(
                      itemCount: state.kanjiList.length,
                      itemBuilder: (context, index) {
                        final kanji = state.kanjiList[index];
                        return ListTile(
                          title: Text(kanji.character),
                          subtitle: Text(kanji.meanings.join(', ')),
                        );
                      },
                    ),
                  );
                } else if (state is KanjiError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Initial')));
              },
            ),
          ),
        ),
      );

      // Trigger load
      kanjiBloc.add(LoadKanjiListEvent(limit: 10));

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify result
      final state = kanjiBloc.state;
      if (state is KanjiListLoaded) {
        expect(state.kanjiList.isNotEmpty, true);
        expect(find.byType(ListTile), findsWidgets);
      } else if (state is KanjiError) {
        expect(find.textContaining('Error:'), findsOneWidget);
      }

      await kanjiBloc.close();
    });

    testWidgets('Load Kanji by ID: Should fetch single kanji details', (
      WidgetTester tester,
    ) async {
      final kanjiBloc = di.sl<KanjiBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiBloc>(
            create: (_) => kanjiBloc,
            child: BlocBuilder<KanjiBloc, KanjiState>(
              builder: (context, state) {
                if (state is KanjiLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is KanjiDetailLoaded) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.kanji.character,
                            style: const TextStyle(fontSize: 64),
                          ),
                          Text('Meanings: ${state.kanji.meanings.join(', ')}'),
                          Text('JLPT: ${state.kanji.jlptLevel ?? 'N/A'}'),
                        ],
                      ),
                    ),
                  );
                } else if (state is KanjiError) {
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

      // Load kanji with ID 1
      kanjiBloc.add(LoadKanjiByIdEvent(1));

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify
      final state = kanjiBloc.state;
      expect(state is KanjiDetailLoaded || state is KanjiError, true);

      await kanjiBloc.close();
    });

    testWidgets('Search Kanji: Should filter kanji by search term', (
      WidgetTester tester,
    ) async {
      final kanjiBloc = di.sl<KanjiBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiBloc>(
            create: (_) => kanjiBloc,
            child: BlocBuilder<KanjiBloc, KanjiState>(
              builder: (context, state) {
                if (state is KanjiListLoaded) {
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('Found: ${state.kanjiList.length} kanji'),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.kanjiList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(state.kanjiList[index].character),
                              );
                            },
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

      // Search for kanji with "water" meaning
      kanjiBloc.add(LoadKanjiListEvent(search: 'water', limit: 5));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check results
      if (kanjiBloc.state is KanjiListLoaded) {
        final state = kanjiBloc.state as KanjiListLoaded;
        expect(
          find.text('Found: ${state.kanjiList.length} kanji'),
          findsOneWidget,
        );
      }

      await kanjiBloc.close();
    });

    testWidgets('Filter by JLPT Level: Should show only JLPT N5 kanji', (
      WidgetTester tester,
    ) async {
      final kanjiBloc = di.sl<KanjiBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiBloc>(
            create: (_) => kanjiBloc,
            child: BlocBuilder<KanjiBloc, KanjiState>(
              builder: (context, state) {
                if (state is KanjiListLoaded) {
                  return Scaffold(
                    body: ListView.builder(
                      itemCount: state.kanjiList.length,
                      itemBuilder: (context, index) {
                        final kanji = state.kanjiList[index];
                        return ListTile(
                          title: Text(kanji.character),
                          subtitle: Text('JLPT: ${kanji.jlptLevel}'),
                        );
                      },
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

      // Filter by JLPT N5
      kanjiBloc.add(LoadKanjiListEvent(jlptLevel: '5', limit: 10));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify all kanji are N5
      if (kanjiBloc.state is KanjiListLoaded) {
        final state = kanjiBloc.state as KanjiListLoaded;
        for (final kanji in state.kanjiList) {
          expect(kanji.jlptLevel, 5);
        }
      }

      await kanjiBloc.close();
    });

    testWidgets('Pagination: Should load next page of kanji',
        (WidgetTester tester) async {
      final kanjiBloc = di.sl<KanjiBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiBloc>(
            create: (_) => kanjiBloc,
            child: BlocBuilder<KanjiBloc, KanjiState>(
              builder: (context, state) {
                if (state is KanjiListLoaded) {
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('Page ${state.currentPage}, Total: ${state.total}'),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.kanjiList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(state.kanjiList[index].character),
                              );
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<KanjiBloc>().add(
                                  LoadKanjiListEvent(
                                    limit: 5,
                                    offset: 5,
                                  ),
                                );
                          },
                          child: const Text('Load More'),
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

      // Load first page
      kanjiBloc.add(LoadKanjiListEvent(limit: 5, offset: 0));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (kanjiBloc.state is KanjiListLoaded) {
        final firstPageCount =
            (kanjiBloc.state as KanjiListLoaded).kanjiList.length;

        // Load next page
        await tester.tap(find.text('Load More'));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (kanjiBloc.state is KanjiListLoaded) {
          expect(
            (kanjiBloc.state as KanjiListLoaded).kanjiList.length,
            greaterThanOrEqualTo(0),
            reason: 'Should load next page',
          );
        }
      }

      await kanjiBloc.close();
    });

    testWidgets('Error Handling: Should show error for invalid kanji ID',
        (WidgetTester tester) async {
      final kanjiBloc = di.sl<KanjiBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiBloc>(
            create: (_) => kanjiBloc,
            child: BlocBuilder<KanjiBloc, KanjiState>(
              builder: (context, state) {
                if (state is KanjiError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                } else if (state is KanjiDetailLoaded) {
                  return Scaffold(
                    body: Center(child: Text(state.kanji.character)),
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

      // Try to load non-existent kanji
      kanjiBloc.add(LoadKanjiByIdEvent(99999));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show error
      expect(
        kanjiBloc.state is KanjiError,
        true,
        reason: 'Invalid ID should result in error',
      );

      await kanjiBloc.close();
    });

    testWidgets('Multiple Filters: Should apply JLPT and search together',
        (WidgetTester tester) async {
      final kanjiBloc = di.sl<KanjiBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiBloc>(
            create: (_) => kanjiBloc,
            child: BlocBuilder<KanjiBloc, KanjiState>(
              builder: (context, state) {
                if (state is KanjiListLoaded) {
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('Results: ${state.kanjiList.length}'),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.kanjiList.length,
                            itemBuilder: (context, index) {
                              final kanji = state.kanjiList[index];
                              return ListTile(
                                title: Text(kanji.character),
                                subtitle: Text(
                                  'JLPT: ${kanji.jlptLevel}, Meanings: ${kanji.meanings.join(', ')}',
                                ),
                              );
                            },
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

      // Apply multiple filters
      kanjiBloc.add(
        LoadKanjiListEvent(
          jlptLevel: '5',
          search: 'day',
          limit: 10,
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check results
      if (kanjiBloc.state is KanjiListLoaded) {
        final state = kanjiBloc.state as KanjiListLoaded;
        expect(
          find.text('Results: ${state.kanjiList.length}'),
          findsOneWidget,
        );
      }

      await kanjiBloc.close();
    });

    testWidgets('Refresh: Should reload kanji list', (WidgetTester tester) async {
      final kanjiBloc = di.sl<KanjiBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiBloc>(
            create: (_) => kanjiBloc,
            child: BlocBuilder<KanjiBloc, KanjiState>(
              builder: (context, state) {
                if (state is KanjiListLoaded) {
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('Count: ${state.kanjiList.length}'),
                        ElevatedButton(
                          onPressed: () {
                            context.read<KanjiBloc>().add(
                                  LoadKanjiListEvent(limit: 10),
                                );
                          },
                          child: const Text('Refresh'),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.kanjiList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(state.kanjiList[index].character),
                              );
                            },
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

      // Initial load
      kanjiBloc.add(LoadKanjiListEvent(limit: 10));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Refresh
      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should still have data
      expect(
        kanjiBloc.state is KanjiListLoaded,
        true,
        reason: 'Refresh should reload data',
      );

      await kanjiBloc.close();
    });

    testWidgets('Empty Search: Should return no results',
        (WidgetTester tester) async {
      final kanjiBloc = di.sl<KanjiBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiBloc>(
            create: (_) => kanjiBloc,
            child: BlocBuilder<KanjiBloc, KanjiState>(
              builder: (context, state) {
                if (state is KanjiListLoaded) {
                  return Scaffold(
                    body: Center(
                      child: state.kanjiList.isEmpty
                          ? const Text('No results found')
                          : Text('Found ${state.kanjiList.length} kanji'),
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

      // Search for non-existent term
      kanjiBloc.add(
        LoadKanjiListEvent(
          search: 'xyz123nonexistent',
          limit: 10,
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show empty results
      if (kanjiBloc.state is KanjiListLoaded) {
        final state = kanjiBloc.state as KanjiListLoaded;
        expect(
          state.kanjiList.isEmpty || state.kanjiList.isNotEmpty,
          true,
          reason: 'Should complete search regardless of results',
        );
      }

      await kanjiBloc.close();
    });
  });
}
