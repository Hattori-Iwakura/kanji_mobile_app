import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:kanji_mobile_v1/features/kanji/data/datasources/kanji_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/kanji/data/repositories/kanji_repository_impl.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/repositories/kanji_repository.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/get_all_kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/get_kanji_by_id.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/recognize_kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/search_kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_bloc.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_event.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../helpers/fixtures/kanji_fixtures.dart';

/// E2E test for complete Kanji search flow
/// Tests the entire user journey from browsing to detail view
void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late KanjiRemoteDataSource remoteDataSource;
  late KanjiRepository repository;
  late GetAllKanji getAllKanji;
  late GetKanjiById getKanjiById;
  late SearchKanji searchKanji;
  late RecognizeKanji recognizeKanji;
  late KanjiBloc kanjiBloc;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));
    dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter =
        dioAdapter; // CRITICAL: Inject mock adapter into Dio
    remoteDataSource = KanjiRemoteDataSourceImpl(dio: dio);
    repository = KanjiRepositoryImpl(remoteDataSource: remoteDataSource);
    getAllKanji = GetAllKanji(repository);
    getKanjiById = GetKanjiById(repository);
    searchKanji = SearchKanji(repository);
    recognizeKanji = RecognizeKanji(repository);
    kanjiBloc = KanjiBloc(
      getAllKanji: getAllKanji,
      getKanjiById: getKanjiById,
      searchKanji: searchKanji,
      recognizeKanji: recognizeKanji,
    );
  });

  tearDown(() {
    kanjiBloc.close();
  });

  Widget createTestApp() {
    return MaterialApp(
      home: BlocProvider.value(
        value: kanjiBloc,
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Kanji Master'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Trigger search
                      context.read<KanjiBloc>().add(
                        const SearchKanjiEvent(query: '日'),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      // Trigger JLPT filter
                      context.read<KanjiBloc>().add(
                        const LoadAllKanjiEvent(jlpt: 5),
                      );
                    },
                  ),
                ],
              ),
              body: BlocBuilder<KanjiBloc, KanjiState>(
                builder: (context, state) {
                  if (state is KanjiLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is KanjiError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<KanjiBloc>().add(
                                const LoadAllKanjiEvent(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is KanjiListLoaded) {
                    if (state.kanjiList.isEmpty) {
                      return const Center(child: Text('No kanji found'));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: state.kanjiList.length,
                      itemBuilder: (context, index) {
                        final kanji = state.kanjiList[index];
                        return InkWell(
                          onTap: () {
                            // Navigate to detail view
                            context.read<KanjiBloc>().add(
                              LoadKanjiByIdEvent(kanji.id),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  kanji.character,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                if (kanji.jlpt != null)
                                  Text(
                                    'N${kanji.jlpt}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is KanjiDetailLoaded) {
                    // Show detail view
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.kanji.character,
                            style: const TextStyle(fontSize: 64),
                          ),
                          Text(state.kanji.meanings),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<KanjiBloc>().add(
                                const LoadAllKanjiEvent(),
                              );
                            },
                            child: const Text('Back to List'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is KanjiSearchLoaded) {
                    if (state.results.isEmpty) {
                      return const Center(child: Text('No kanji found'));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        final kanji = state.results[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                kanji.character,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Welcome to Kanji Master'));
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Load all kanji
                  kanjiBloc.add(const LoadAllKanjiEvent());
                },
                child: const Icon(Icons.refresh),
              ),
            );
          },
        ),
      ),
    );
  }

  group('Kanji Search E2E Flow', () {
    testWidgets('should complete full browse → search → view detail flow', (
      WidgetTester tester,
    ) async {
      // Mock API: Load all kanji
      dioAdapter.onGet(
        '/kanji',
        (server) => server.reply(200, {
          'statusCode': 200,
          'data': {
            'data': [tKanjiJson1, tKanjiJson2, tKanjiJson3],
            'total': 3,
            'limit': 20,
            'offset': 0,
          },
          'timestamp': '2024-01-01T00:00:00.000Z',
        }),
      );

      // Listen to bloc state changes
      final states = <KanjiState>[];
      kanjiBloc.stream.listen(states.add);

      // Mock API: Search for '日'
      dioAdapter.onGet(
        '/kanji',
        (server) => server.reply(200, {
          'statusCode': 200,
          'data': {
            'data': [tKanjiJson1],
            'total': 1,
            'limit': 20,
            'offset': 0,
          },
          'timestamp': '2024-01-01T00:00:00.000Z',
        }),
        queryParameters: {'query': '日'},
      );

      // Mock API: Get kanji by ID
      dioAdapter.onGet(
        '/kanji/1',
        (server) => server.reply(200, {
          'statusCode': 200,
          'data': tKanjiJson1,
          'timestamp': '2024-01-01T00:00:00.000Z',
        }),
      );

      // Step 1: Launch app and verify initial state
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Step 2: Tap refresh to load all kanji
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle(); // Wait for all async operations to complete

      // Debug: Check final state
      print('Final state: ${kanjiBloc.state}');
      print('All state transitions: $states');
      if (kanjiBloc.state is KanjiError) {
        print('Error message: ${(kanjiBloc.state as KanjiError).message}');
      }

      // Verify grid is displayed with 3 kanji
      expect(find.text('日'), findsOneWidget);
      expect(find.text('月'), findsOneWidget);
      expect(find.text('火'), findsOneWidget);
      expect(find.text('N5'), findsNWidgets(3));

      // Step 3: Tap search to search for '日'
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump(); // Trigger event
      await tester.pumpAndSettle(); // Wait for search results

      // Verify search results show only '日'
      expect(find.text('日'), findsOneWidget);
      expect(find.text('月'), findsNothing);
      expect(find.text('火'), findsNothing);

      // Step 4: Tap on kanji to view detail
      await tester.tap(find.text('日'));
      await tester.pump(); // Trigger event
      await tester.pumpAndSettle(); // Wait for detail to load

      // Verify detail view loaded (BLoC state changed to single kanji)
      expect(kanjiBloc.state, isA<KanjiDetailLoaded>());
      final loadedState = kanjiBloc.state as KanjiDetailLoaded;
      expect(loadedState.kanji.id, 1);
    });

    testWidgets('should handle error and retry successfully', (
      WidgetTester tester,
    ) async {
      // Mock API: First call fails
      bool firstCall = true;
      dioAdapter.onGet('/kanji', (server) {
        if (firstCall) {
          firstCall = false;
          return server.reply(500, {
            'statusCode': 500,
            'message': 'Server error',
            'timestamp': '2024-01-01T00:00:00.000Z',
          });
        }
        return server.reply(200, {
          'statusCode': 200,
          'data': {
            'data': [tKanjiJson1, tKanjiJson2],
            'total': 2,
            'limit': 20,
            'offset': 0,
          },
          'timestamp': '2024-01-01T00:00:00.000Z',
        });
      });

      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Trigger load
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify error message is displayed
      expect(
        find.text('Server error. Please try again later.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify success after retry
      expect(find.text('日'), findsOneWidget);
      expect(find.text('月'), findsOneWidget);
    });

    testWidgets('should filter by JLPT level', (WidgetTester tester) async {
      // Mock API: Filter by JLPT N5
      dioAdapter.onGet(
        '/kanji',
        (server) => server.reply(200, {
          'statusCode': 200,
          'data': {
            'data': [tKanjiJson1, tKanjiJson2, tKanjiJson3],
            'total': 3,
            'limit': 20,
            'offset': 0,
          },
          'timestamp': '2024-01-01T00:00:00.000Z',
        }),
        queryParameters: {'jlptLevel': '5'},
      );

      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Tap filter icon
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.text('日'), findsOneWidget);
      expect(find.text('月'), findsOneWidget);
      expect(find.text('火'), findsOneWidget);
      expect(find.text('N5'), findsNWidgets(3));
    });

    testWidgets('should display empty state when no results', (
      WidgetTester tester,
    ) async {
      // Mock API: Empty results
      dioAdapter.onGet(
        '/kanji',
        (server) => server.reply(200, {
          'statusCode': 200,
          'data': {'data': [], 'total': 0, 'limit': 20, 'offset': 0},
          'timestamp': '2024-01-01T00:00:00.000Z',
        }),
        queryParameters: {'query': 'xyz'},
      );

      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Trigger search with no results
      kanjiBloc.add(const SearchKanjiEvent(query: 'xyz'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify empty state
      expect(find.text('No kanji found'), findsOneWidget);
    });

    testWidgets('should navigate back from detail to list', (
      WidgetTester tester,
    ) async {
      // Mock API: Load all kanji
      dioAdapter.onGet(
        '/kanji',
        (server) => server.reply(200, {
          'statusCode': 200,
          'data': {
            'data': [tKanjiJson1, tKanjiJson2],
            'total': 2,
            'limit': 20,
            'offset': 0,
          },
          'timestamp': '2024-01-01T00:00:00.000Z',
        }),
      );

      // Mock API: Get kanji by ID
      dioAdapter.onGet(
        '/kanji/1',
        (server) => server.reply(200, {
          'statusCode': 200,
          'data': tKanjiJson1,
          'timestamp': '2024-01-01T00:00:00.000Z',
        }),
      );

      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Load all kanji
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('日'), findsOneWidget);
      expect(find.text('月'), findsOneWidget);

      // Tap to view detail
      await tester.tap(find.text('日'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify detail loaded
      final detailState = kanjiBloc.state as KanjiDetailLoaded;
      expect(detailState.kanji.id, 1);

      // Navigate back by loading all again
      await tester.tap(find.text('Back to List'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify back to list
      expect(find.text('日'), findsOneWidget);
      expect(find.text('月'), findsOneWidget);
    });

    testWidgets('should handle network timeout gracefully', (
      WidgetTester tester,
    ) async {
      // Mock API: Timeout error
      dioAdapter.onGet(
        '/kanji',
        (server) => server.throws(
          404,
          DioException.connectionTimeout(
            timeout: const Duration(seconds: 30),
            requestOptions: RequestOptions(path: '/kanji'),
          ),
        ),
      );

      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Trigger load
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.textContaining('Network connection failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should refresh list after viewing detail', (
      WidgetTester tester,
    ) async {
      // Mock API: Load all kanji
      dioAdapter.onGet(
        '/kanji',
        (server) => server.reply(200, {
          'statusCode': 200,
          'data': {
            'data': [tKanjiJson1, tKanjiJson2, tKanjiJson3],
            'total': 3,
            'limit': 20,
            'offset': 0,
          },
          'timestamp': '2024-01-01T00:00:00.000Z',
        }),
      );

      // Mock API: Get kanji by ID
      dioAdapter.onGet(
        '/kanji/2',
        (server) => server.reply(200, {
          'statusCode': 200,
          'data': tKanjiJson2,
          'timestamp': '2024-01-01T00:00:00.000Z',
        }),
      );

      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Load all kanji
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify 3 kanji displayed
      expect(find.text('日'), findsOneWidget);
      expect(find.text('月'), findsOneWidget);
      expect(find.text('火'), findsOneWidget);

      // Tap on second kanji
      await tester.tap(find.text('月'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify detail loaded for 月
      final detailState = kanjiBloc.state as KanjiDetailLoaded;
      expect(detailState.kanji.character, '月');

      // Back to list
      await tester.tap(find.text('Back to List'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify all 3 kanji displayed again
      expect(find.text('日'), findsOneWidget);
      expect(find.text('月'), findsOneWidget);
      expect(find.text('火'), findsOneWidget);
    });
  });
}
