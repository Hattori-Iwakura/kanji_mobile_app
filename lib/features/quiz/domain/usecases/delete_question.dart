import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/quiz_repository.dart';

/// UseCase for deleting a question from a quiz
class DeleteQuestion {
  final QuizRepository repository;

  DeleteQuestion(this.repository);

  Future<Either<Failure, void>> call({
    required String quizId,
    required String questionId,
  }) async {
    return await repository.deleteQuestion(
      quizId: quizId,
      questionId: questionId,
    );
  }
}
