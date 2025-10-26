import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/bloc/flashcard_deck_bloc.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/bloc/flashcard_deck_event.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/bloc/flashcard_deck_state.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/pages/deck_list_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures/flashcard_fixtures.dart';

class MockFlashcardDeckBloc
    extends MockBloc<FlashcardDeckEvent, FlashcardDeckState>
    implements FlashcardDeckBloc {}

void main() {
  late MockFlashcardDeckBloc mockBloc;

  setUp(() {
    mockBloc = MockFlashcardDeckBloc();
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<FlashcardDeckBloc>.value(
        value: mockBloc,
        child: const DeckListPage(),
      ),
    );
  }

  group('DeckListPage Widget Tests', () {
    testWidgets('should display loading indicator when state is loading', (
      tester,
    ) async {
      // Arrange
      when(() => mockBloc.state).thenReturn(FlashcardDeckLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty message when no decks', (tester) async {
      // Arrange
      when(() => mockBloc.state).thenReturn(const FlashcardDecksLoaded([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No decks yet'), findsOneWidget);
      expect(
        find.text('Create your first deck to start learning'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.style_outlined), findsOneWidget);
    });

    testWidgets('should display empty search results message', (tester) async {
      // Arrange
      when(() => mockBloc.state).thenReturn(const FlashcardDecksLoaded([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No decks found'), findsOneWidget);
      expect(find.text('Try a different search term'), findsOneWidget);
    });

    testWidgets('should display deck list when decks are loaded', (
      tester,
    ) async {
      // Arrange
      when(() => mockBloc.state).thenReturn(
        FlashcardDecksLoaded([tFlashcardDeckNew1, tFlashcardDeckNew2]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('JLPT N5 Kanji'), findsOneWidget);
      expect(find.text('JLPT N4 Kanji'), findsOneWidget);
      expect(find.text('Total Decks'), findsOneWidget);
      expect(find.text('Total Cards'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Total decks count
    });

    testWidgets('should display stats header with correct counts', (
      tester,
    ) async {
      // Arrange
      when(() => mockBloc.state).thenReturn(
        FlashcardDecksLoaded([tFlashcardDeckNew1, tFlashcardDeckNew2]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Total Decks'), findsOneWidget);
      expect(find.text('Total Cards'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // 2 decks
      expect(find.text('10'), findsOneWidget); // 10 total cards (5 + 5)
    });

    testWidgets('should show search bar', (tester) async {
      // Arrange
      when(
        () => mockBloc.state,
      ).thenReturn(FlashcardDecksLoaded([tFlashcardDeckNew1]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search decks...'), findsOneWidget);
    });

    testWidgets('should show clear button when search has text', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockBloc.state,
      ).thenReturn(FlashcardDecksLoaded([tFlashcardDeckNew1]));
      when(() => mockBloc.add(any())).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'N5');
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should clear search when clear button is tapped', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockBloc.state,
      ).thenReturn(FlashcardDecksLoaded([tFlashcardDeckNew1]));
      when(() => mockBloc.add(any())).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'N5');
      await tester.pumpAndSettle();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
      verify(() => mockBloc.add(const LoadFlashcardDecksEvent())).called(1);
    });

    testWidgets('should show floating action button', (tester) async {
      // Arrange
      when(
        () => mockBloc.state,
      ).thenReturn(FlashcardDecksLoaded([tFlashcardDeckNew1]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('New Deck'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show error message when state is error', (
      tester,
    ) async {
      // Arrange
      when(() => mockBloc.state).thenReturn(FlashcardDeckLoading());
      whenListen(
        mockBloc,
        Stream.fromIterable([
          FlashcardDeckLoading(),
          const FlashcardDeckError('Failed to load decks'),
        ]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to load decks'), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog', (tester) async {
      // Arrange
      when(
        () => mockBloc.state,
      ).thenReturn(FlashcardDecksLoaded([tFlashcardDeckNew1]));
      when(() => mockBloc.add(any())).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap the more menu button
      final moreButton = find.byIcon(Icons.more_vert).first;
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Tap delete option
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Delete Deck?'), findsOneWidget);
      expect(
        find.textContaining('Are you sure you want to delete'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsWidgets);
    });

    testWidgets('should emit delete event when delete is confirmed', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockBloc.state,
      ).thenReturn(FlashcardDecksLoaded([tFlashcardDeckNew1]));
      when(() => mockBloc.add(any())).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open more menu
      final moreButton = find.byIcon(Icons.more_vert).first;
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.text('Delete').first);
      await tester.pumpAndSettle();

      // Confirm delete
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      // Assert
      verify(
        () => mockBloc.add(DeleteFlashcardDeckEvent(tFlashcardDeckNew1.id)),
      ).called(1);
    });

    testWidgets('should show snackbar when deck is deleted', (tester) async {
      // Arrange
      when(() => mockBloc.state).thenReturn(FlashcardDeckLoading());
      whenListen(
        mockBloc,
        Stream.fromIterable([
          FlashcardDecksLoaded([tFlashcardDeckNew1]),
          FlashcardDeckDeleted(tFlashcardDeckNew1.id),
        ]),
      );
      when(() => mockBloc.add(any())).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Deck deleted successfully'), findsOneWidget);
    });
  });
}
