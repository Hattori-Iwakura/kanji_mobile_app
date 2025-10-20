import '../repositories/quiz_repository.dart';

class ReorderQuestionsUseCase {
  final QuizRepository repository;

  ReorderQuestionsUseCase(this.repository);

  Future<void> call({
    required int quizId,
    required List<Map<String, int>> questionOrders,
  }) {
    return repository.reorderQuestions(
      quizId: quizId,
      questionOrders: questionOrders,
    );
  }
}
