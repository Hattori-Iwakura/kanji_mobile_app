import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_result.dart';
import '../repositories/quiz_repository.dart';

/// Use case for completing quiz
class CompleteQuiz {
  final QuizRepository repository;

  CompleteQuiz(this.repository);

  Future<Either<Failure, QuizResult>> call({
    required String quizId,
    required int timeSpent,
  }) async {
    return await repository.completeQuiz(quizId: quizId, timeSpent: timeSpent);
  }
}
