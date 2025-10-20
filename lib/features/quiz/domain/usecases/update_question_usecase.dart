import '../entities/quiz_question_entity.dart';
import '../repositories/quiz_repository.dart';

class UpdateQuestionUseCase {
  final QuizRepository repository;

  UpdateQuestionUseCase(this.repository);

  Future<QuizQuestionEntity> call({
    required int quizId,
    required int questionId,
    String? questionText,
    String? questionType,
    List<String>? options,
    String? correctAnswer,
  }) {
    return repository.updateQuestion(
      quizId: quizId,
      questionId: questionId,
      questionText: questionText,
      questionType: questionType,
      options: options,
      correctAnswer: correctAnswer,
    );
  }
}
