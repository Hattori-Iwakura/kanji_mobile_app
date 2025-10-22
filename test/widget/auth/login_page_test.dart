import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/bloc/auth_event.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/bloc/auth_state.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/pages/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(const LoginEvent(account: '', password: ''));
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('should render login form with text fields', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert - Find text fields
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      ); // account + password
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should trigger login event when form is valid', (
      tester,
    ) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      const testAccount = 'testuser';
      const testPassword = 'password123';

      // act - enter valid credentials
      await tester.enterText(find.byType(TextFormField).first, testAccount);
      await tester.enterText(find.byType(TextFormField).last, testPassword);
      await tester.pumpAndSettle();

      // Scroll to make button visible
      await tester.ensureVisible(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      final loginButton = find.byType(ElevatedButton).first;
      await tester.tap(loginButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // assert - verify LoginEvent was added
      verify(
        () => mockAuthBloc.add(
          const LoginEvent(account: testAccount, password: testPassword),
        ),
      ).called(1);
    });

    testWidgets('should show loading indicator when state is AuthLoading', (
      tester,
    ) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error snackbar when state is AuthError', (
      tester,
    ) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          const AuthInitial(),
          const AuthError(message: 'Invalid credentials'),
        ]),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('password field should accept input', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      const testPassword = 'mySecretPassword';

      // act
      await tester.enterText(find.byType(TextFormField).last, testPassword);
      await tester.pump();

      // assert
      expect(find.text(testPassword), findsOneWidget);
    });

    testWidgets('account field should accept input', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      const testAccount = 'myaccount';

      // act
      await tester.enterText(find.byType(TextFormField).first, testAccount);
      await tester.pump();

      // assert
      expect(find.text(testAccount), findsOneWidget);
    });

    testWidgets('should not trigger login with empty fields', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // act - scroll to button and tap without entering data
      await tester.ensureVisible(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      final loginButton = find.byType(ElevatedButton).first;
      await tester.tap(loginButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // assert - LoginEvent should not be called
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('should have form validation', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert - Form should exist
      expect(find.byType(Form), findsOneWidget);
    });
  });
}
