import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

class KanjiMasterApp extends StatelessWidget {
  const KanjiMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanji Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // TODO: Add routing
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.translate, size: 100, color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Kanji Master',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Learning Japanese Made Easy',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
