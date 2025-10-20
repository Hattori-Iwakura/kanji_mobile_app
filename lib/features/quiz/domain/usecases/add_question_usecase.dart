import '../entities/quiz_question_entity.dart';
import '../repositories/quiz_repository.dart';

class AddQuestionUseCase {
  final QuizRepository repository;

  AddQuestionUseCase(this.repository);

  Future<QuizQuestionEntity> call({
    required int quizId,
    required int kanjiId,
    required String questionText,
    required String questionType,
    required List<String> options,
    required String correctAnswer,
  }) {
    return repository.addQuestion(
      quizId: quizId,
      kanjiId: kanjiId,
      questionText: questionText,
      questionType: questionType,
      options: options,
      correctAnswer: correctAnswer,
    );
  }
}
