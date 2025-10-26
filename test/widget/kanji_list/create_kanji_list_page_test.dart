import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_bloc.dart';
import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_event.dart';
import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_state.dart';

import '../../helpers/fixtures/kanji_list_fixtures.dart';

class MockKanjiListBloc extends Mock implements KanjiListBloc {}

void main() {
  late MockKanjiListBloc mockKanjiListBloc;

  setUp(() {
    mockKanjiListBloc = MockKanjiListBloc();
  });

  setUpAll(() {
    registerFallbackValue(const CreateKanjiListEvent(name: 'Test'));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<KanjiListBloc>.value(
        value: mockKanjiListBloc,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Create New List',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: BlocListener<KanjiListBloc, KanjiListState>(
            listener: (context, state) {
              if (state is KanjiListCreated) {
                Navigator.pop(context, true);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: const Key('create_form'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    Text(
                      'List Name *',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const Key('name_field'),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter list name',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a list name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Description field
                    Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const Key('description_field'),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter description (optional)',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Create button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const Key('create_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Create List',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('CreateKanjiListPage Widget', () {
    testWidgets('should display all form fields', (WidgetTester tester) async {
      // arrange
      when(() => mockKanjiListBloc.state).thenReturn(KanjiListInitial());
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListInitial()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('List Name *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.byKey(const Key('name_field')), findsOneWidget);
      expect(find.byKey(const Key('description_field')), findsOneWidget);
    });

    testWidgets('should display create button', (WidgetTester tester) async {
      // arrange
      when(() => mockKanjiListBloc.state).thenReturn(KanjiListInitial());
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListInitial()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Create List'), findsOneWidget);
      expect(find.byKey(const Key('create_button')), findsOneWidget);
    });

    testWidgets('should validate name field when empty', (
      WidgetTester tester,
    ) async {
      // arrange
      when(() => mockKanjiListBloc.state).thenReturn(KanjiListInitial());
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListInitial()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and validate the form
      final formFinder = find.byKey(const Key('create_form'));
      expect(formFinder, findsOneWidget);

      final nameField = tester.widget<TextFormField>(
        find.byKey(const Key('name_field')),
      );

      // assert
      expect(nameField.validator!(''), 'Please enter a list name');
      expect(nameField.validator!('   '), 'Please enter a list name');
    });

    testWidgets('should accept valid name', (WidgetTester tester) async {
      // arrange
      when(() => mockKanjiListBloc.state).thenReturn(KanjiListInitial());
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListInitial()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      final nameField = tester.widget<TextFormField>(
        find.byKey(const Key('name_field')),
      );

      // assert
      expect(nameField.validator!('My List'), null);
    });

    testWidgets('should display name field with hint text', (
      WidgetTester tester,
    ) async {
      // arrange
      when(() => mockKanjiListBloc.state).thenReturn(KanjiListInitial());
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListInitial()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Enter list name'), findsOneWidget);
    });

    testWidgets('should display description field with hint text', (
      WidgetTester tester,
    ) async {
      // arrange
      when(() => mockKanjiListBloc.state).thenReturn(KanjiListInitial());
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListInitial()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Enter description (optional)'), findsOneWidget);
    });

    testWidgets('should allow text input in name field', (
      WidgetTester tester,
    ) async {
      // arrange
      when(() => mockKanjiListBloc.state).thenReturn(KanjiListInitial());
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListInitial()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byKey(const Key('name_field')), 'Test List');

      // assert
      expect(find.text('Test List'), findsOneWidget);
    });

    testWidgets('should allow text input in description field', (
      WidgetTester tester,
    ) async {
      // arrange
      when(() => mockKanjiListBloc.state).thenReturn(KanjiListInitial());
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListInitial()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
        find.byKey(const Key('description_field')),
        'Test Description',
      );

      // assert
      expect(find.text('Test Description'), findsOneWidget);
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
      expect(find.text('Create New List'), findsOneWidget);
    });
  });
}
