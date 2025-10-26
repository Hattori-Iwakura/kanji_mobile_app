import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

/// UseCase for adding a question to a quiz
class AddQuestion {
  final QuizRepository repository;

  AddQuestion(this.repository);

  Future<Either<Failure, Question>> call({
    required String quizId,
    required String type,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
    String? explanation,
    int points = 10,
    List<String> meanings = const [],
  }) {
    return repository.addQuestion(
      quizId: quizId,
      type: type,
      questionText: questionText,
      options: options,
      correctAnswer: correctAnswer,
      explanation: explanation,
      points: points,
      meanings: meanings,
    );
  }
}
