import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

class UpdateQuestionUseCase {
  final QuizRepository repository;

  UpdateQuestionUseCase(this.repository);

  Future<Question> call({
    required int quizId,
    required int questionId,
    QuestionType? type,
    String? questionText,
    String? correctAnswer,
    List<String>? options,
    String? explanation,
    int? points,
    List<String>? meanings,
    int? order,
  }) async {
    return await repository.updateQuestion(
      quizId: quizId,
      questionId: questionId,
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
