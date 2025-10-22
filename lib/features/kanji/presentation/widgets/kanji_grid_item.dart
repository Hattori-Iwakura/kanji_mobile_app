import 'package:flutter/material.dart';
import '../../domain/entities/kanji.dart';

/// Grid item widget for displaying a single kanji
class KanjiGridItem extends StatelessWidget {
  final Kanji kanji;
  final VoidCallback onTap;

  const KanjiGridItem({super.key, required this.kanji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kanji character - large
              Text(
                kanji.character,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Noto Sans JP',
                ),
              ),
              const SizedBox(height: 4),
              // Primary meaning
              Text(
                kanji.meaningsList.first,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // JLPT or Grade badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (kanji.jlpt != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getJlptColor(kanji.jlpt!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'N${kanji.jlpt}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (kanji.grade != null && kanji.jlpt == null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'G${kanji.grade}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getJlptColor(int jlpt) {
    switch (jlpt) {
      case 5:
        return Colors.green[300]!;
      case 4:
        return Colors.lightGreen[300]!;
      case 3:
        return Colors.yellow[300]!;
      case 2:
        return Colors.orange[300]!;
      case 1:
        return Colors.red[300]!;
      default:
        return Colors.grey[300]!;
    }
  }
}
