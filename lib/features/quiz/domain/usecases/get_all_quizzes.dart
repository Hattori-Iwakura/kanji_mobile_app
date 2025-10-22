import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

/// Use case for getting all quizzes
class GetAllQuizzes {
  final QuizRepository repository;

  GetAllQuizzes(this.repository);

  Future<Either<Failure, List<Quiz>>> call() async {
    return await repository.getAllQuizzes();
  }
}
