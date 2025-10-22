import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/quiz_repository.dart';

/// Use case for submitting quiz answer
class SubmitQuizAnswer {
  final QuizRepository repository;

  SubmitQuizAnswer(this.repository);

  Future<Either<Failure, bool>> call({
    required String quizId,
    required String questionId,
    required String answer,
  }) async {
    return await repository.submitAnswer(
      quizId: quizId,
      questionId: questionId,
      answer: answer,
    );
  }
}
