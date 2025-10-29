import 'package:flutter/material.dart';
import '../../../features/flashcard/presentation/pages/flashcard_deck_list_page.dart';
import '../../../features/kanji/presentation/pages/kanji_list_page.dart';
import '../widgets/fancy_bottom_app_bar.dart';
import 'home_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    KanjiListPage(),
    FlashcardDeckListPage(),
    Center(
      child: Text('Profile Page', style: TextStyle(color: Colors.white)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: FancyBottomAppBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.tealAccent.shade700,
              child: const Icon(Icons.play_arrow, color: Colors.black87),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
