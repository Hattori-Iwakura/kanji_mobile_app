import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class UpdateQuizUseCase {
  final QuizRepository repository;

  UpdateQuizUseCase(this.repository);

  Future<Quiz> call({
    required int quizId,
    String? title,
    String? description,
    bool? isPublic,
  }) async {
    return await repository.updateQuiz(
      quizId: quizId,
      title: title,
      description: description,
      isPublic: isPublic,
    );
  }
}
