import 'package:equatable/equatable.dart';

/// Entity representing a quiz
class Quiz extends Equatable {
  final String id;
  final String title;
  final String description;
  final String difficulty; // EASY, MEDIUM, HARD
  final int totalQuestions;
  final int timeLimit; // in seconds, 0 = no limit
  final int passingScore; // percentage (0-100)
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.totalQuestions,
    required this.timeLimit,
    required this.passingScore,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    difficulty,
    totalQuestions,
    timeLimit,
    passingScore,
    isPublished,
    createdAt,
    updatedAt,
  ];

  /// Check if quiz has time limit
  bool get hasTimeLimit => timeLimit > 0;

  /// Get formatted time limit
  String get formattedTimeLimit {
    if (!hasTimeLimit) return 'No limit';
    final minutes = timeLimit ~/ 60;
    final seconds = timeLimit % 60;
    if (seconds == 0) return '$minutes min';
    return '$minutes:${seconds.toString().padLeft(2, '0')} min';
  }

  /// Get difficulty color
  String get difficultyColor {
    switch (difficulty.toUpperCase()) {
      case 'EASY':
        return 'green';
      case 'MEDIUM':
        return 'orange';
      case 'HARD':
        return 'red';
      default:
        return 'grey';
    }
  }
}
