import 'package:flutter/material.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanji App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routes: {
        '/': (ctx) => const LoginPage(),
        '/home': (ctx) => const HomePage(),
      },
    );
  }
}
