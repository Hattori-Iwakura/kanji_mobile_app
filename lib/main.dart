import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'core/constants/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/main_home_page.dart';
import 'features/kanji/presentation/pages/kanji_list_page.dart';
import 'features/kanji/presentation/pages/kanji_detail_page.dart';
import 'features/kanji/presentation/pages/admin_kanji_list_page.dart';
import 'features/kanji/presentation/bloc/kanji_bloc.dart';
import 'features/kanji/presentation/bloc/kanji_event.dart';
import 'features/kanji/presentation/bloc/kanji_state.dart';
import 'features/kanji_recognition/presentation/bloc/kanji_recognition_bloc.dart';
import 'features/kanji_recognition/presentation/pages/kanji_drawing_page.dart';
import 'features/flashcard/presentation/bloc/flashcard_deck_bloc.dart';
import 'features/flashcard/presentation/bloc/flashcard_deck_event.dart';
import 'features/flashcard/presentation/pages/flashcard_deck_list_page.dart';

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
      title: 'Kanji Learning App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Auto dark mode based on system
      routes: {
        '/': (ctx) => const LoginPage(),
        '/home': (ctx) => const MainHomePage(),
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
        '/flashcard': (ctx) => BlocProvider(
          create: (context) =>
              di.sl<FlashcardDeckBloc>()..add(LoadUserDecksEvent()),
          child: const FlashcardDeckListPage(),
        ),
      },
      onGenerateRoute: (settings) {
        // Route wrapper: old kanji_list_page uses int ID, new KanjiDetailPage uses String character
        // This wrapper loads the kanji and navigates with its character
        if (settings.name == '/kanji-detail') {
          final kanjiId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) =>
                  di.sl<KanjiBloc>()..add(LoadKanjiByIdEvent(kanjiId)),
              child: BlocBuilder<KanjiBloc, KanjiState>(
                builder: (context, state) {
                  if (state is KanjiDetailLoaded) {
                    // Navigate to new KanjiDetailPage with character
                    Future.microtask(() {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) =>
                              KanjiDetailPage(character: state.kanji.character),
                        ),
                      );
                    });
                  }
                  // Show loading while fetching kanji
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          );
        }
        return null;
      },
    );
  }
}
