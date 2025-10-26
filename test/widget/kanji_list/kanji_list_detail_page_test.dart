import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_bloc.dart';
import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_event.dart';
import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_state.dart';
import 'package:kanji_mobile_v1/features/kanji_list/presentation/widgets/kanji_list_item_widget.dart';

import '../../helpers/fixtures/kanji_list_fixtures.dart';

class MockKanjiListBloc extends Mock implements KanjiListBloc {}

void main() {
  late MockKanjiListBloc mockKanjiListBloc;

  setUp(() {
    mockKanjiListBloc = MockKanjiListBloc();
  });

  setUpAll(() {
    registerFallbackValue(const LoadKanjiListByIdEvent(1));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'List Details',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            BlocBuilder<KanjiListBloc, KanjiListState>(
              bloc: mockKanjiListBloc,
              builder: (context, state) {
                if (state is KanjiListLoaded) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {},
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit List'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Delete List',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
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
                    ],
                  ),
                );
              }

              if (state is KanjiListLoaded) {
                final list = state.list;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // List header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (list.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              list.description!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                list.isPublic ? Icons.public : Icons.lock,
                                color: Colors.white.withOpacity(0.5),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                list.isPublic ? 'Public' : 'Private',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.person,
                                color: Colors.white.withOpacity(0.5),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                list.userName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${list.items.length} kanji',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.white24),

                    // Kanji items
                    Expanded(
                      child: list.items.isEmpty
                          ? const Center(
                              child: Text(
                                'No kanji in this list',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: list.items.length,
                              itemBuilder: (context, index) {
                                final item = list.items[index];
                                return KanjiListItemWidget(
                                  item: item,
                                  onTap: () {},
                                  onRemove: () {},
                                );
                              },
                            ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  group('KanjiListDetailPage Widget', () {
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
      },
    );

    testWidgets('should display error message when state is KanjiListError', (
      WidgetTester tester,
    ) async {
      // arrange
      const errorMessage = 'List not found';
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
    });

    testWidgets('should display list details when state is KanjiListLoaded', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(KanjiListLoaded(tKanjiListById));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListLoaded(tKanjiListById)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('JLPT N5 Basics'), findsOneWidget);
      expect(find.text('Essential kanji for JLPT N5'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('2 kanji'), findsOneWidget);
    });

    testWidgets('should display public/private status', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(KanjiListLoaded(tKanjiListById));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListLoaded(tKanjiListById)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Public'), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('should display kanji items when list has items', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(KanjiListLoaded(tKanjiListById));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListLoaded(tKanjiListById)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(KanjiListItemWidget), findsNWidgets(2));
    });

    testWidgets('should display empty message when list has no items', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(KanjiListLoaded(tKanjiList3NoItems));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListLoaded(tKanjiList3NoItems)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('No kanji in this list'), findsOneWidget);
      expect(find.byType(KanjiListItemWidget), findsNothing);
    });

    testWidgets('should display menu button when list is loaded', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(KanjiListLoaded(tKanjiListById));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListLoaded(tKanjiListById)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should display edit and delete options in menu', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(KanjiListLoaded(tKanjiListById));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListLoaded(tKanjiListById)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Edit List'), findsOneWidget);
      expect(find.text('Delete List'), findsOneWidget);
    });

    testWidgets('should display correct item count', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        () => mockKanjiListBloc.state,
      ).thenReturn(KanjiListLoaded(tKanjiListById));
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListLoaded(tKanjiListById)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('2 kanji'), findsOneWidget);
    });
  });
}
