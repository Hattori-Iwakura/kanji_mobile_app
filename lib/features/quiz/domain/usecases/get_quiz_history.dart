import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/quiz_result.dart';
import '../repositories/quiz_repository.dart';

/// Use case for getting quiz history
class GetQuizHistory {
  final QuizRepository repository;

  GetQuizHistory(this.repository);

  Future<Either<Failure, List<QuizResult>>> call() async {
    return await repository.getQuizHistory();
  }
}
