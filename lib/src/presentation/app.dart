import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/flashcard/presentation/bloc/flashcard_bloc.dart';
import '../../features/kanji/presentation/bloc/kanji_bloc.dart';
import '../../features/quiz/presentation/bloc/quiz_bloc.dart';
import '../../injection_container.dart';
import 'pages/auth_wrapper.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();

    final theme = base.copyWith(
      useMaterial3: true,
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.tealAccent,
        secondary: Colors.amberAccent,
        surface: const Color(0xFF0B0F14),
      ),
      scaffoldBackgroundColor: const Color(0xFF0B0F14),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white70,
        displayColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white10,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider(create: (context) => sl<KanjiBloc>()),
        BlocProvider(create: (context) => sl<FlashcardBloc>()),
        BlocProvider(create: (context) => sl<QuizBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kanji Mobile',
        theme: theme,
        home: const AuthWrapper(),
      ),
    );
  }
}
