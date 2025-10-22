import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/di/injection.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/bloc/auth_state.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/pages/login_page.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_page_test.mocks.dart';

@GenerateMocks([AuthBloc])
void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(mockAuthBloc.state).thenReturn(AuthInitial());
    when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    // Register mock in GetIt for widget testing
    if (getIt.isRegistered<AuthBloc>()) {
      getIt.unregister<AuthBloc>();
    }
    getIt.registerFactory<AuthBloc>(() => mockAuthBloc);
  });

  tearDown(() async {
    await mockAuthBloc.close();
    if (getIt.isRegistered<AuthBloc>()) {
      getIt.unregister<AuthBloc>();
    }
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(home: LoginPage());
  }

  group('LoginPage Widget Tests', () {
    testWidgets('should display all UI elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check title and subtitle
      expect(find.text('Kanji Master'), findsOneWidget);
      expect(find.text('Learning Japanese Made Easy'), findsOneWidget);

      // Check form fields
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      ); // Account and Password
      expect(find.text('Account or Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Check buttons
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);

      // Check social login placeholders
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Facebook'), findsOneWidget);
    });

    testWidgets('should show validation errors when form is empty', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Check validation errors (using the actual error messages from Validators)
      expect(find.text('Account or Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      expect(passwordField, findsOneWidget);

      // Initially password is obscured, so icon should be visibility_off
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap to show password
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      // After tapping, icon should change to visibility (password visible)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Icon should be back to visibility_off (password hidden)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('should show loading widget when state is AuthLoading', (
      tester,
    ) async {
      when(mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Check loading widget is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error snackbar when state is AuthError', (
      tester,
    ) async {
      const errorMessage = 'Invalid credentials';

      // Start with initial state
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([const AuthError(message: errorMessage)]),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Trigger the error state
      await tester.pump();

      // Check snackbar is displayed
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should show social login coming soon message', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Google login button (scroll to it first if needed)
      await tester.ensureVisible(find.text('Continue with Google'));
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();

      // Check snackbar with coming soon message
      expect(find.text('Google login - Coming soon'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
