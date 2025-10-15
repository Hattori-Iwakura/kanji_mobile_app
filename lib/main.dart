import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/kanji/presentation/pages/kanji_list_page.dart';
import 'features/kanji/presentation/pages/kanji_detail_page.dart';
import 'features/kanji/presentation/pages/admin_kanji_list_page.dart';
import 'features/kanji/presentation/bloc/kanji_bloc.dart';
import 'features/kanji/presentation/bloc/kanji_event.dart';
import 'features/kanji_recognition/presentation/bloc/kanji_recognition_bloc.dart';
import 'features/kanji_recognition/presentation/pages/kanji_drawing_page.dart';

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
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.dark, // Force dark mode
      routes: {
        '/': (ctx) => const LoginPage(),
        '/home': (ctx) => const HomePage(),
        '/kanji-list': (ctx) => BlocProvider(
          create: (context) =>
              di.sl<KanjiBloc>()..add(const LoadAllKanjiEvent()),
          child: const KanjiListPage(),
        ),
        '/admin-kanji': (ctx) => const AdminKanjiListPage(),
        '/kanji-recognition': (ctx) => BlocProvider(
          create: (context) => di.sl<KanjiRecognitionBloc>(),
          child: const KanjiDrawingPage(),
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/kanji-detail') {
          final kanjiId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) =>
                  di.sl<KanjiBloc>()..add(LoadKanjiByIdEvent(kanjiId)),
              child: const KanjiDetailPage(),
            ),
          );
        }
        return null;
      },
    );
  }
}
