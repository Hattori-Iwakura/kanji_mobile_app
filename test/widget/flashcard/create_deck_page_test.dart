import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/bloc/flashcard_deck_bloc.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/bloc/flashcard_deck_event.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/bloc/flashcard_deck_state.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/pages/create_deck_page.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_bloc.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_event.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures/flashcard_fixtures.dart';
import '../../helpers/fixtures/kanji_fixtures.dart';

class MockFlashcardDeckBloc
    extends MockBloc<FlashcardDeckEvent, FlashcardDeckState>
    implements FlashcardDeckBloc {}

class MockKanjiBloc extends MockBloc<KanjiEvent, KanjiState>
    implements KanjiBloc {}

void main() {
  late MockFlashcardDeckBloc mockFlashcardDeckBloc;
  late MockKanjiBloc mockKanjiBloc;

  setUpAll(() {
    registerFallbackValue(const LoadAllKanjiEvent());
    registerFallbackValue(
      const CreateFlashcardDeckEvent(name: '', kanjiIds: []),
    );
  });

  setUp(() {
    mockFlashcardDeckBloc = MockFlashcardDeckBloc();
    mockKanjiBloc = MockKanjiBloc();
  });

  tearDown(() {
    mockFlashcardDeckBloc.close();
    mockKanjiBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<FlashcardDeckBloc>.value(value: mockFlashcardDeckBloc),
          BlocProvider<KanjiBloc>.value(value: mockKanjiBloc),
        ],
        child: const CreateDeckPage(),
      ),
    );
  }

  group('CreateDeckPage Widget Tests', () {
    testWidgets('should display page title', (tester) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Create New Deck'), findsOneWidget);
    });

    testWidgets('should display name field with label', (tester) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Deck Name *'), findsOneWidget);
      expect(find.text('e.g., JLPT N5 Kanji'), findsOneWidget);
    });

    testWidgets('should display description field', (tester) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Description (Optional)'), findsOneWidget);
      expect(find.text('Describe what this deck is for...'), findsOneWidget);
    });

    testWidgets('should display selected kanji section', (tester) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Selected Kanji'), findsOneWidget);
      expect(find.text('0 selected'), findsOneWidget);
    });

    testWidgets('should display loading indicator when kanji is loading', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display kanji grid when loaded', (tester) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiListLoaded(tKanjiList));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('日'), findsOneWidget); // First kanji
      expect(find.text('月'), findsOneWidget); // Second kanji
    });

    testWidgets('should display empty message when no kanji', (tester) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(const KanjiListLoaded([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No kanji available'), findsOneWidget);
    });

    testWidgets('should update selected count when kanji is tapped', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiListLoaded(tKanjiList));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initially 0 selected
      expect(find.text('0 selected'), findsOneWidget);

      // Tap first kanji
      await tester.tap(find.text('日'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('should toggle kanji selection on tap', (tester) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiListLoaded(tKanjiList));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap to select
      await tester.tap(find.text('日'));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);

      // Tap again to deselect
      await tester.tap(find.text('日'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('0 selected'), findsOneWidget);
    });

    testWidgets('should display create button', (tester) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Create Deck'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should show validation error when name is empty', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiListLoaded(tKanjiList));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Select a kanji
      await tester.tap(find.text('日'));
      await tester.pumpAndSettle();

      // Tap create button without entering name
      await tester.tap(find.text('Create Deck'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a deck name'), findsOneWidget);
    });

    testWidgets('should show snackbar when no kanji selected', (tester) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiListLoaded(tKanjiList));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., JLPT N5 Kanji'),
        'Test Deck',
      );
      await tester.pumpAndSettle();

      // Tap create without selecting kanji
      await tester.tap(find.text('Create Deck'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please select at least one kanji'), findsOneWidget);
    });

    testWidgets('should emit create event when form is valid', (tester) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiListLoaded(tKanjiList));
      when(() => mockFlashcardDeckBloc.add(any())).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., JLPT N5 Kanji'),
        'Test Deck',
      );
      await tester.pumpAndSettle();

      // Enter description
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Describe what this deck is for...'),
        'Test Description',
      );
      await tester.pumpAndSettle();

      // Select a kanji
      await tester.tap(find.text('日'));
      await tester.pumpAndSettle();

      // Tap create
      await tester.tap(find.text('Create Deck'));
      await tester.pumpAndSettle();

      // Assert
      verify(
        () => mockFlashcardDeckBloc.add(
          any(
            that: isA<CreateFlashcardDeckEvent>()
                .having((e) => e.name, 'name', 'Test Deck')
                .having((e) => e.description, 'description', 'Test Description')
                .having((e) => e.kanjiIds, 'kanjiIds', [tKanji1.id]),
          ),
        ),
      ).called(1);
    });

    testWidgets('should show success message and pop when deck created', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiInitial());

      whenListen(
        mockFlashcardDeckBloc,
        Stream.fromIterable([
          FlashcardDeckInitial(),
          FlashcardDeckCreated(tFlashcardDeckNew1),
        ]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Deck created successfully!'), findsOneWidget);
    });

    testWidgets('should show error message when creation fails', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiInitial());

      whenListen(
        mockFlashcardDeckBloc,
        Stream.fromIterable([
          FlashcardDeckInitial(),
          const FlashcardDeckError('Failed to create deck'),
        ]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to create deck'), findsOneWidget);
    });

    testWidgets('should disable button while submitting', (tester) async {
      // Arrange
      when(
        () => mockFlashcardDeckBloc.state,
      ).thenReturn(FlashcardDeckInitial());
      when(() => mockKanjiBloc.state).thenReturn(KanjiListLoaded(tKanjiList));
      when(() => mockFlashcardDeckBloc.add(any())).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., JLPT N5 Kanji'),
        'Test Deck',
      );
      await tester.tap(find.text('日'));
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Create Deck'));
      await tester.pump();

      // Assert
      expect(find.text('Creating...'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Creating...'),
      );
      expect(button.onPressed, isNull);
    });
  });
}
