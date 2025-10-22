import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

/// Use case for getting quiz questions
class GetQuizQuestions {
  final QuizRepository repository;

  GetQuizQuestions(this.repository);

  Future<Either<Failure, List<Question>>> call(String quizId) async {
    return await repository.getQuizQuestions(quizId);
  }
}
