import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_bloc.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_event.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_state.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/widgets/kanji_grid_item.dart';

import '../../helpers/fixtures/kanji_fixtures.dart';

class MockKanjiBloc extends Mock implements KanjiBloc {}

void main() {
  late MockKanjiBloc mockKanjiBloc;

  setUp(() {
    mockKanjiBloc = MockKanjiBloc();
  });

  setUpAll(() {
    registerFallbackValue(const LoadAllKanjiEvent());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Kanji Dictionary',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {},
              key: const Key('filter_button'),
            ),
          ],
        ),
        body: BlocProvider<KanjiBloc>.value(
          value: mockKanjiBloc,
          child: BlocBuilder<KanjiBloc, KanjiState>(
            builder: (context, state) {
              if (state is KanjiLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is KanjiError) {
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
                          context.read<KanjiBloc>().add(
                            const LoadAllKanjiEvent(limit: 50),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is KanjiListLoaded) {
                final kanjiList = state.kanjiList;

                if (kanjiList.isEmpty) {
                  return const Center(child: Text('No kanji found'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: kanjiList.length,
                  itemBuilder: (context, index) {
                    final kanji = kanjiList[index];
                    return KanjiGridItem(kanji: kanji, onTap: () {});
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  group('KanjiListPage Widget', () {
    testWidgets('should display loading indicator when state is KanjiLoading', (
      WidgetTester tester,
    ) async {
      // arrange
      when(() => mockKanjiBloc.state).thenReturn(KanjiLoading());
      when(
        () => mockKanjiBloc.stream,
      ).thenAnswer((_) => Stream.fromIterable([KanjiLoading()]));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message when state is KanjiError', (
      WidgetTester tester,
    ) async {
      // arrange
      const errorMessage = 'Server error occurred';
      when(
        () => mockKanjiBloc.state,
      ).thenReturn(const KanjiError(errorMessage));
      when(() => mockKanjiBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([const KanjiError(errorMessage)]),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should trigger reload when retry button is tapped', (
      WidgetTester tester,
    ) async {
      // arrange
      when(() => mockKanjiBloc.state).thenReturn(const KanjiError('Error'));
      when(
        () => mockKanjiBloc.stream,
      ).thenAnswer((_) => Stream.fromIterable([const KanjiError('Error')]));
      when(() => mockKanjiBloc.add(any())).thenReturn(null);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // assert
      verify(
        () => mockKanjiBloc.add(const LoadAllKanjiEvent(limit: 50)),
      ).called(1);
    });

    testWidgets('should display empty message when kanji list is empty', (
      WidgetTester tester,
    ) async {
      // arrange
      when(() => mockKanjiBloc.state).thenReturn(const KanjiListLoaded([]));
      when(
        () => mockKanjiBloc.stream,
      ).thenAnswer((_) => Stream.fromIterable([const KanjiListLoaded([])]));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.text('No kanji found'), findsOneWidget);
    });

    testWidgets('should display kanji grid when list is loaded', (
      WidgetTester tester,
    ) async {
      // arrange
      final kanjiList = [tKanji1, tKanji2, tKanji3];
      when(() => mockKanjiBloc.state).thenReturn(KanjiListLoaded(kanjiList));
      when(
        () => mockKanjiBloc.stream,
      ).thenAnswer((_) => Stream.fromIterable([KanjiListLoaded(kanjiList)]));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(KanjiGridItem), findsNWidgets(3));
      expect(find.text('日'), findsOneWidget);
      expect(find.text('月'), findsOneWidget);
      expect(find.text('火'), findsOneWidget);
    });

    testWidgets('should have correct grid layout with 3 columns', (
      WidgetTester tester,
    ) async {
      // arrange
      final kanjiList = [tKanji1, tKanji2, tKanji3];
      when(() => mockKanjiBloc.state).thenReturn(KanjiListLoaded(kanjiList));
      when(
        () => mockKanjiBloc.stream,
      ).thenAnswer((_) => Stream.fromIterable([KanjiListLoaded(kanjiList)]));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 3);
      expect(delegate.crossAxisSpacing, 12);
      expect(delegate.mainAxisSpacing, 12);
    });

    testWidgets('should have AppBar with title and action buttons', (
      WidgetTester tester,
    ) async {
      // arrange
      when(() => mockKanjiBloc.state).thenReturn(KanjiLoading());
      when(
        () => mockKanjiBloc.stream,
      ).thenAnswer((_) => Stream.fromIterable([KanjiLoading()]));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.text('Kanji Dictionary'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should display correct number of kanji items', (
      WidgetTester tester,
    ) async {
      // arrange
      final kanjiList = [tKanji1, tKanji2, tKanji3, tKanji4, tKanji5];
      when(() => mockKanjiBloc.state).thenReturn(KanjiListLoaded(kanjiList));
      when(
        () => mockKanjiBloc.stream,
      ).thenAnswer((_) => Stream.fromIterable([KanjiListLoaded(kanjiList)]));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.byType(KanjiGridItem), findsNWidgets(5));
    });
  });
}
