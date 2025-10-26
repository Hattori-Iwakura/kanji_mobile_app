import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

/// UseCase for updating a question
class UpdateQuestion {
  final QuizRepository repository;

  UpdateQuestion(this.repository);

  Future<Either<Failure, Question>> call({
    required String quizId,
    required String questionId,
    String? type,
    String? questionText,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    int? points,
    List<String>? meanings,
  }) async {
    return await repository.updateQuestion(
      quizId: quizId,
      questionId: questionId,
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
