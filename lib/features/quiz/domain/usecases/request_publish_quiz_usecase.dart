import '../repositories/quiz_repository.dart';

class RequestPublishQuizUseCase {
  final QuizRepository repository;

  RequestPublishQuizUseCase(this.repository);

  Future<void> call(int quizId, String? message) {
    return repository.requestPublish(quizId, message);
  }
}
