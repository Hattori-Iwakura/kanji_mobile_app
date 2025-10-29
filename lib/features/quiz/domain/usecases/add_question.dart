import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

class AddQuestionUseCase {
  final QuizRepository repository;

  AddQuestionUseCase(this.repository);

  Future<Question> call({
    required int quizId,
    required QuestionType type,
    required String questionText,
    required String correctAnswer,
    List<String>? options,
    String? explanation,
    int? points,
    List<String>? meanings,
    int? order,
  }) async {
    return await repository.addQuestion(
      quizId: quizId,
      type: type,
      questionText: questionText,
      correctAnswer: correctAnswer,
      options: options,
      explanation: explanation,
      points: points,
      meanings: meanings,
      order: order,
    );
  }
}
