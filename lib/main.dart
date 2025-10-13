import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/kanji/presentation/bloc/kanji_bloc.dart';
import 'features/kanji/presentation/bloc/kanji_list_bloc.dart';
import 'features/kanji/presentation/pages/kanji_list_page.dart';
import 'injection_container.dart' as di;

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
      title: 'Học Kanji',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => di.sl<KanjiBloc>()),
          BlocProvider(create: (context) => di.sl<KanjiListBloc>()),
        ],
        child: const KanjiListPage(),
      ),
    );
  }
}
