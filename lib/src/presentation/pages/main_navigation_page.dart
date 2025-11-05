import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../features/flashcard/presentation/pages/flashcard_deck_list_page.dart';
import '../../../features/kanji/presentation/pages/kanji_list_page.dart';
import '../../../features/quiz/presentation/pages/quiz_list_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../../../injection_container.dart';
import '../widgets/fancy_bottom_app_bar.dart';
import 'home_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const KanjiListPage(),
      const QuizListPage(),
      const FlashcardDeckListPage(),
      ProfilePage(apiClient: sl<ApiClient>()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: _pages[_currentIndex],
      bottomNavigationBar: FancyBottomAppBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
