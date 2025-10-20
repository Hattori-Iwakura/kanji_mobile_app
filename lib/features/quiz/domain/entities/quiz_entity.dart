import 'package:equatable/equatable.dart';

class QuizEntity extends Equatable {
  final int id;
  final String title;
  final String? description;
  final int userId;
  final bool isPublic;
  final int totalQuestions;
  final DateTime createAt;
  final DateTime updateAt;

  const QuizEntity({
    required this.id,
    required this.title,
    this.description,
    required this.userId,
    required this.isPublic,
    required this.totalQuestions,
    required this.createAt,
    required this.updateAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    userId,
    isPublic,
    totalQuestions,
    createAt,
    updateAt,
  ];
}
