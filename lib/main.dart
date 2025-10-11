import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:kanji_flutter/data/remote/kanji_remote_data_source.dart';
import 'package:kanji_flutter/data/repositories/kanji_repository_hybrid.dart';
import 'package:kanji_flutter/data/datasources/kanji_local_database.dart';
import 'package:kanji_flutter/domain/repositories/kanji_repository.dart';
import 'package:kanji_flutter/presentation/pages/kanji_library_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final backendHost = _defaultBackendHost();
  final remote = KanjiRemoteDataSource(baseUrl: backendHost);
  final localDatabase = KanjiLocalDatabase();

  // Sử dụng hybrid repository
  final repo = KanjiRepositoryHybrid(
    remoteDataSource: remote,
    localDatabase: localDatabase,
  );

  runApp(KanjiLibraryApp(repo: repo));
}

class KanjiLibraryApp extends StatelessWidget {
  final KanjiRepository repo;

  const KanjiLibraryApp({Key? key, required this.repo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanji Library',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: KanjiLibraryPage(repo: repo),
      debugShowCheckedModeBanner: false,
    );
  }
}

String _defaultBackendHost() {
  if (kIsWeb) return 'http://localhost:3000';
  if (Platform.isAndroid) return 'http://10.0.2.2:3000'; // Android emulator
  return 'http://localhost:3000'; // iOS simulator / desktop / physical device -> dùng IP dev nếu trên device thật
}
