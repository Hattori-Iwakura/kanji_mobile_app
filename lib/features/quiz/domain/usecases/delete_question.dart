import '../repositories/quiz_repository.dart';

class DeleteQuestionUseCase {
  final QuizRepository repository;

  DeleteQuestionUseCase(this.repository);

  Future<void> call({required int quizId, required int questionId}) async {
    return await repository.deleteQuestion(
      quizId: quizId,
      questionId: questionId,
    );
  }
}
