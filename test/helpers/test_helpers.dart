import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper function to pump a widget with MaterialApp wrapper
Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  List<BlocProvider>? providers,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: providers != null
          ? MultiBlocProvider(providers: providers, child: widget)
          : widget,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.purple,
        ),
      ),
    ),
  );
}

/// Helper to find widgets by type and key
extension WidgetTesterX on WidgetTester {
  /// Find a widget by its key
  Finder byKey(String key) => find.byKey(Key(key));

  /// Find a button with specific text
  Finder buttonWithText(String text) =>
      find.widgetWithText(ElevatedButton, text);

  /// Find a TextField with specific label
  Finder textFieldWithLabel(String label) =>
      find.widgetWithText(TextField, label);
}

/// Helper to verify navigation
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }

  void reset() {
    pushedRoutes.clear();
    poppedRoutes.clear();
  }
}
