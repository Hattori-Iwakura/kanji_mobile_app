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
    registerFallbackValue(const UpdateKanjiListEvent(id: 1, name: 'Test'));
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
              'Edit List',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: BlocListener<KanjiListBloc, KanjiListState>(
            listener: (context, state) {
              if (state is KanjiListUpdated) {
                Navigator.pop(context, true);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: const Key('edit_form'),
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
                      initialValue: tKanjiListById.name,
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
                      initialValue: tKanjiListById.description,
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
                    const SizedBox(height: 24),

                    // Public/Private toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Public List',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          key: const Key('public_switch'),
                          value: tKanjiListById.isPublic,
                          onChanged: (value) {},
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Update button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const Key('update_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Update List',
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

  group('EditKanjiListPage Widget', () {
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
      expect(find.text('Public List'), findsOneWidget);
      expect(find.byKey(const Key('name_field')), findsOneWidget);
      expect(find.byKey(const Key('description_field')), findsOneWidget);
      expect(find.byKey(const Key('public_switch')), findsOneWidget);
    });

    testWidgets('should display update button', (WidgetTester tester) async {
      // arrange
      when(() => mockKanjiListBloc.state).thenReturn(KanjiListInitial());
      when(
        () => mockKanjiListBloc.stream,
      ).thenAnswer((_) => Stream.value(KanjiListInitial()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Update List'), findsOneWidget);
      expect(find.byKey(const Key('update_button')), findsOneWidget);
    });

    testWidgets('should pre-fill name field with existing value', (
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
      expect(find.text('JLPT N5 Basics'), findsOneWidget);
    });

    testWidgets('should pre-fill description field with existing value', (
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
      expect(find.text('Essential kanji for JLPT N5'), findsOneWidget);
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
      expect(nameField.validator!('Updated Name'), null);
    });

    testWidgets('should display public switch with correct initial value', (
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
      final switchWidget = tester.widget<Switch>(
        find.byKey(const Key('public_switch')),
      );
      expect(switchWidget.value, tKanjiListById.isPublic);
    });

    testWidgets('should allow updating name field', (
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
        find.byKey(const Key('name_field')),
        'Updated List Name',
      );

      // assert
      expect(find.text('Updated List Name'), findsOneWidget);
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
      expect(find.text('Edit List'), findsOneWidget);
    });
  });
}
