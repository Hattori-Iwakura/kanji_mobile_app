import 'package:equatable/equatable.dart';
import '../../../domain/entities/quiz.dart';

abstract class QuizListState extends Equatable {
  const QuizListState();

  @override
  List<Object?> get props => [];
}

class QuizListInitial extends QuizListState {}

class QuizListLoading extends QuizListState {}

class QuizListLoaded extends QuizListState {
  final List<Quiz> quizzes;

  const QuizListLoaded(this.quizzes);

  @override
  List<Object?> get props => [quizzes];
}

class QuizListError extends QuizListState {
  final String message;

  const QuizListError(this.message);

  @override
  List<Object?> get props => [message];
}
