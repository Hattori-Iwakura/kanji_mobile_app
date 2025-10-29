import 'package:flutter/material.dart';

class FancyBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FancyBottomAppBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: const Color(0xFF08121A),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => onTap(0),
                  icon: Icon(
                    Icons.home,
                    color: currentIndex == 0
                        ? Colors.tealAccent
                        : Colors.white70,
                  ),
                  tooltip: 'Trang chủ',
                ),
                IconButton(
                  onPressed: () => onTap(1),
                  icon: Icon(
                    Icons.menu_book,
                    color: currentIndex == 1
                        ? Colors.tealAccent
                        : Colors.white70,
                  ),
                  tooltip: 'Kanji',
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => onTap(2),
                  icon: Icon(
                    Icons.style,
                    color: currentIndex == 2
                        ? Colors.tealAccent
                        : Colors.white70,
                  ),
                  tooltip: 'Flashcards',
                ),
                IconButton(
                  onPressed: () => onTap(3),
                  icon: Icon(
                    Icons.person,
                    color: currentIndex == 3
                        ? Colors.tealAccent
                        : Colors.white70,
                  ),
                  tooltip: 'Tài khoản',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
