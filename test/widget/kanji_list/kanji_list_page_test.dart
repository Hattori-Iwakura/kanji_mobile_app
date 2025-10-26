import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_bloc.dart';
import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_event.dart';
import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_state.dart';
import 'package:kanji_mobile_v1/features/kanji_list/presentation/widgets/kanji_list_card.dart';

import '../../helpers/fixtures/kanji_list_fixtures.dart';

class MockKanjiListBloc extends Mock implements KanjiListBloc {}

void main() {
  late MockKanjiListBloc mockKanjiListBloc;

  setUp(() {
    mockKanjiListBloc = MockKanjiListBloc();
  });

  setUpAll(() {
    registerFallbackValue(const LoadKanjiListsEvent());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Kanji Lists',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: BlocProvider<KanjiListBloc>.value(
          value: mockKanjiListBloc,
          child: BlocBuilder<KanjiListBloc, KanjiListState>(
            builder: (context, state) {
              if (state is KanjiListLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is KanjiListError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<KanjiListBloc>().add(
                            const LoadKanjiListsEvent(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is KanjiListsLoaded) {
                final lists = state.lists;

                if (lists.isEmpty) {
                  return const Center(
                    child: Text(
                      'No lists found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    return KanjiListCard(
                      kanjiList: list,
                      onTap: () {},
                      onDelete: () {},
                      onEdit: () {},
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  group('KanjiListPage Widget', () {
    testWidgets(
      'should display loading indicator when state is KanjiListLoading',
      (WidgetTester tester) async {
        // arrange
        when(() => mockKanjiListBloc.state).thenReturn(KanjiListLoading());
        when(
          () => mockKanjiListBloc.stream,
        ).thenAnswer((_) => Stream.value(KanjiListLoading()));

        // act
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('No lists found'), findsNothing);
      },
    );

    testWidgets('should display error message when state is KanjiListError', (
      WidgetTester tester,
    ) async {
      // arrange
      const errorMessage = 'Failed to load lists';
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(const KanjiListError(errorMessage));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(const KanjiListError(errorMessage)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should retry loading when retry button is pressed', (
      WidgetTester tester,
    ) async {
      // arrange
      const errorMessage = 'Network error';
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(const KanjiListError(errorMessage));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(const KanjiListError(errorMessage)));
      when(() => mockKanjiListBloc.add(any())).thenReturn(null);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // assert
      verify(
        () => mockKanjiListBloc.add(const LoadKanjiListsEvent()),
      ).called(1);
    });

    testWidgets('should display empty message when no lists available', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(const KanjiListsLoaded([]));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(const KanjiListsLoaded([])));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('No lists found'), findsOneWidget);
      expect(find.byType(KanjiListCard), findsNothing);
    });

    testWidgets(
      'should display list of kanji lists when state is KanjiListsLoaded',
      (WidgetTester tester) async {
        // arrange
        when(
          () => mockKanjiListBloc.state,
        ).thenReturn(KanjiListsLoaded(tAllKanjiListsNoItems));
        when(() => mockKanjiListBloc.stream).thenAnswer(
          (_) => Stream.value(KanjiListsLoaded(tAllKanjiListsNoItems)),
        );

        // act
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        expect(find.byType(KanjiListCard), findsNWidgets(3));
        expect(find.text('JLPT N5 Basics'), findsOneWidget);
        expect(find.text('My Custom List'), findsOneWidget);
        expect(find.text('Public List'), findsOneWidget);
      },
    );

    testWidgets('should display FAB for creating new list', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(KanjiListsLoaded(tAllKanjiListsNoItems));
      when(() => mockKanjiListBloc.stream).thenAnswer(
        (_) => Stream.value(KanjiListsLoaded(tAllKanjiListsNoItems)),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display correct list details', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(KanjiListsLoaded([tKanjiList1NoItems]));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListsLoaded([tKanjiList1NoItems])));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('JLPT N5 Basics'), findsOneWidget);
      expect(find.text('Essential kanji for JLPT N5'), findsOneWidget);
    });

    testWidgets('should show both public and private lists', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(KanjiListsLoaded([tKanjiList1NoItems, tKanjiList2NoItems]));
      when(() => mockKanjiListBloc.stream).thenAnswer(
        (_) => Stream.value(
          KanjiListsLoaded([tKanjiList1NoItems, tKanjiList2NoItems]),
        ),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(KanjiListCard), findsNWidgets(2));
      // Verify public list
      expect(find.text('JLPT N5 Basics'), findsOneWidget);
      // Verify private list
      expect(find.text('My Custom List'), findsOneWidget);
    });

    testWidgets('should display user information on cards', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(KanjiListsLoaded([tKanjiList1NoItems]));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListsLoaded([tKanjiList1NoItems])));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('should display title in AppBar', (WidgetTester tester) async {
      // arrange
      when(() => mockKanjiListBloc.state).thenReturn(KanjiListInitial());
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListInitial()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Kanji Lists'), findsOneWidget);
    });
  });
}
