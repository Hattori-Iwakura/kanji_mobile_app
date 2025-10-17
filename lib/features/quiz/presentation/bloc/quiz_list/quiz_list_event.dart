import 'package:equatable/equatable.dart';
import '../../../domain/entities/quiz_enums.dart';

abstract class QuizListEvent extends Equatable {
  const QuizListEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuizzesEvent extends QuizListEvent {
  final bool myQuizzes;
  final bool? publicOnly;
  final String? category;
  final QuizDifficulty? difficulty;

  const LoadQuizzesEvent({
    this.myQuizzes = false,
    this.publicOnly,
    this.category,
    this.difficulty,
  });

  @override
  List<Object?> get props => [myQuizzes, publicOnly, category, difficulty];
}

class RefreshQuizzesEvent extends QuizListEvent {}

class FilterChangedEvent extends QuizListEvent {
  final String? category;
  final QuizDifficulty? difficulty;

  const FilterChangedEvent({this.category, this.difficulty});

  @override
  List<Object?> get props => [category, difficulty];
}
