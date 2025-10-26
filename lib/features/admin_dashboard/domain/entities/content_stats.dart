import 'package:equatable/equatable.dart';

/// Entity representing content statistics from admin dashboard
class ContentStats extends Equatable {
  final int totalKanji;
  final int totalKanjiLists;
  final int totalFlashcardDecks;
  final int totalQuizzes;
  final int totalUsers;
  final int activeUsers;

  const ContentStats({
    required this.totalKanji,
    required this.totalKanjiLists,
    required this.totalFlashcardDecks,
    required this.totalQuizzes,
    required this.totalUsers,
    required this.activeUsers,
  });

  @override
  List<Object?> get props => [
    totalKanji,
    totalKanjiLists,
    totalFlashcardDecks,
    totalQuizzes,
    totalUsers,
    activeUsers,
  ];
}
