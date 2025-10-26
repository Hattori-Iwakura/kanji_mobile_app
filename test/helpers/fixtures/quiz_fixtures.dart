/// Quiz test fixtures for testing
library;

import 'package:kanji_mobile_v1/features/quiz/domain/entities/question.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz_result.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz_answer.dart';

// Test Quiz entities
final tQuiz1 = Quiz(
  id: '1',
  title: 'JLPT N5 Practice Quiz',
  description: 'Test your basic kanji knowledge',
  difficulty: 'EASY',
  totalQuestions: 10,
  timeLimit: 600, // 10 minutes
  passingScore: 70,
  isPublished: true,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
);

final tQuiz2 = Quiz(
  id: '2',
  title: 'JLPT N4 Intermediate Quiz',
  description: 'Intermediate level kanji quiz',
  difficulty: 'MEDIUM',
  totalQuestions: 20,
  timeLimit: 1200, // 20 minutes
  passingScore: 75,
  isPublished: true,
  createdAt: DateTime(2024, 1, 2),
  updatedAt: DateTime(2024, 1, 2),
);

final tQuiz3 = Quiz(
  id: '3',
  title: 'Advanced Kanji Challenge',
  description: 'Advanced level quiz with drawing questions',
  difficulty: 'HARD',
  totalQuestions: 15,
  timeLimit: 0, // No time limit
  passingScore: 80,
  isPublished: false,
  createdAt: DateTime(2024, 1, 3),
  updatedAt: DateTime(2024, 1, 3),
);

// List of test quizzes
final tQuizList = [tQuiz1, tQuiz2, tQuiz3];
final tPublishedQuizList = [tQuiz1, tQuiz2];
final tEmptyQuizList = <Quiz>[];

// Test Question entities - MULTIPLE_CHOICE type
final tQuestionMultipleChoice1 = Question(
  id: '1',
  quizId: '1',
  type: 'MULTIPLE_CHOICE',
  questionText: 'What does 日 mean?',
  options: ['sun', 'moon', 'fire', 'water'],
  correctAnswer: 'sun',
  explanation: '日 (にち/ひ) means sun or day',
  points: 10,
  orderIndex: 0,
  createdAt: DateTime(2024, 1, 1),
);

final tQuestionMultipleChoice2 = Question(
  id: '2',
  quizId: '1',
  type: 'MULTIPLE_CHOICE',
  questionText: 'What is the onyomi reading of 月?',
  options: ['ゲツ', 'ニチ', 'カ', 'スイ'],
  correctAnswer: 'ゲツ',
  explanation: '月 can be read as ゲツ or ガツ',
  points: 10,
  orderIndex: 1,
  createdAt: DateTime(2024, 1, 1),
);

// Test Question - TRUE_FALSE type
final tQuestionTrueFalse1 = Question(
  id: '3',
  quizId: '1',
  type: 'TRUE_FALSE',
  questionText: '火 means water',
  options: ['True', 'False'],
  correctAnswer: 'False',
  explanation: '火 means fire, not water',
  points: 10,
  orderIndex: 2,
  createdAt: DateTime(2024, 1, 1),
);

final tQuestionTrueFalse2 = Question(
  id: '4',
  quizId: '1',
  type: 'TRUE_FALSE',
  questionText: '木 can be read as き',
  options: ['True', 'False'],
  correctAnswer: 'True',
  explanation: '木 is commonly read as き (tree)',
  points: 10,
  orderIndex: 3,
  createdAt: DateTime(2024, 1, 1),
);

// Test Question - FILL_IN_BLANK type
final tQuestionFillInBlank1 = Question(
  id: '5',
  quizId: '1',
  type: 'FILL_IN_BLANK',
  questionText: 'The kanji for water is ___',
  options: [],
  correctAnswer: '水',
  explanation: '水 (みず) means water',
  points: 15,
  orderIndex: 4,
  createdAt: DateTime(2024, 1, 1),
);

final tQuestionFillInBlank2 = Question(
  id: '6',
  quizId: '1',
  type: 'FILL_IN_BLANK',
  questionText: 'The kunyomi reading of 日 is ___',
  options: [],
  correctAnswer: 'ひ',
  explanation: '日 can be read as ひ or か',
  points: 15,
  orderIndex: 5,
  createdAt: DateTime(2024, 1, 1),
);

// Test Question - DRAWING type
final tQuestionDrawing1 = Question(
  id: '7',
  quizId: '3',
  type: 'DRAWING',
  questionText: 'Draw the kanji for: sun, day',
  options: [],
  correctAnswer: '日',
  explanation: 'Draw the kanji 日',
  points: 20,
  orderIndex: 0,
  createdAt: DateTime(2024, 1, 3),
  meanings: ['sun', 'day'],
);

final tQuestionDrawing2 = Question(
  id: '8',
  quizId: '3',
  type: 'DRAWING',
  questionText: 'Draw the kanji for: water',
  options: [],
  correctAnswer: '水',
  explanation: 'Draw the kanji 水',
  points: 20,
  orderIndex: 1,
  createdAt: DateTime(2024, 1, 3),
  meanings: ['water'],
);

final tQuestionDrawing3 = Question(
  id: '9',
  quizId: '3',
  type: 'DRAWING',
  questionText: 'Draw the kanji for: tree, wood',
  options: [],
  correctAnswer: '木',
  explanation: 'Draw the kanji 木',
  points: 20,
  orderIndex: 2,
  createdAt: DateTime(2024, 1, 3),
  meanings: ['tree', 'wood'],
);

// List of all test questions
final tQuestionList = [
  tQuestionMultipleChoice1,
  tQuestionMultipleChoice2,
  tQuestionTrueFalse1,
  tQuestionTrueFalse2,
  tQuestionFillInBlank1,
  tQuestionFillInBlank2,
];

final tQuestionDrawingList = [
  tQuestionDrawing1,
  tQuestionDrawing2,
  tQuestionDrawing3,
];

final tAllQuestionTypes = [
  tQuestionMultipleChoice1,
  tQuestionTrueFalse1,
  tQuestionFillInBlank1,
  tQuestionDrawing1,
];

// Test QuizAnswer entities
final tQuizAnswer1 = QuizAnswer(
  questionId: '1',
  userAnswer: 'sun',
  isCorrect: true,
  pointsEarned: 10,
  answeredAt: DateTime(2024, 1, 1, 10, 5),
);

final tQuizAnswer2 = QuizAnswer(
  questionId: '2',
  userAnswer: 'ニチ',
  isCorrect: false,
  pointsEarned: 0,
  answeredAt: DateTime(2024, 1, 1, 10, 6),
);

final tQuizAnswer3Drawing = QuizAnswer(
  questionId: '7',
  userAnswer: '日',
  isCorrect: true,
  pointsEarned: 20,
  answeredAt: DateTime(2024, 1, 3, 15, 10),
);

// Test QuizResult entities
final tQuizResult1 = QuizResult(
  id: '1',
  userId: '1',
  quizId: '1',
  totalQuestions: 10,
  correctAnswers: 8,
  incorrectAnswers: 2,
  skippedQuestions: 0,
  totalPoints: 100,
  earnedPoints: 80,
  scorePercentage: 80.0,
  timeSpent: 480, // 8 minutes
  isPassed: true,
  answers: [tQuizAnswer1],
  completedAt: DateTime(2024, 1, 1, 10, 15),
  createdAt: DateTime(2024, 1, 1, 10, 0),
);

final tQuizResult2 = QuizResult(
  id: '2',
  userId: '1',
  quizId: '2',
  totalQuestions: 20,
  correctAnswers: 13,
  incorrectAnswers: 7,
  skippedQuestions: 0,
  totalPoints: 200,
  earnedPoints: 130,
  scorePercentage: 65.0,
  timeSpent: 900, // 15 minutes
  isPassed: false,
  answers: [tQuizAnswer2],
  completedAt: DateTime(2024, 1, 2, 14, 30),
  createdAt: DateTime(2024, 1, 2, 14, 0),
);

final tQuizResultDrawing = QuizResult(
  id: '3',
  userId: '1',
  quizId: '3',
  totalQuestions: 3,
  correctAnswers: 3,
  incorrectAnswers: 0,
  skippedQuestions: 0,
  totalPoints: 60,
  earnedPoints: 60,
  scorePercentage: 100.0,
  timeSpent: 300, // 5 minutes
  isPassed: true,
  answers: [tQuizAnswer3Drawing],
  completedAt: DateTime(2024, 1, 3, 16, 00),
  createdAt: DateTime(2024, 1, 3, 15, 0),
);

// JSON responses
final tQuiz1Json = {
  'id': '1',
  'title': 'JLPT N5 Practice Quiz',
  'description': 'Test your basic kanji knowledge',
  'difficulty': 'EASY',
  'totalQuestions': 10,
  'timeLimit': 600,
  'passingScore': 70,
  'isPublished': true,
  'createdAt': '2024-01-01T00:00:00.000Z',
  'updatedAt': '2024-01-01T00:00:00.000Z',
};

final tQuiz2Json = {
  'id': '2',
  'title': 'JLPT N4 Intermediate',
  'description': 'Intermediate level practice',
  'difficulty': 'MEDIUM',
  'totalQuestions': 20,
  'timeLimit': 1200,
  'passingScore': 75,
  'isPublished': true,
  'createdAt': '2024-01-02T00:00:00.000Z',
  'updatedAt': '2024-01-02T00:00:00.000Z',
};

// For backwards compatibility
final tQuizJson = tQuiz1Json;

final tQuestionMultipleChoice1Json = {
  'id': '1',
  'quizId': '1',
  'type': 'MULTIPLE_CHOICE',
  'questionText': 'What does 日 mean?',
  'options': ['sun', 'moon', 'fire', 'water'],
  'correctAnswer': 'sun',
  'explanation': '日 (にち/ひ) means sun or day',
  'points': 10,
  'orderIndex': 0,
  'createdAt': '2024-01-01T00:00:00.000Z',
  'meanings': [],
};

final tQuestionTrueFalse1Json = {
  'id': '3',
  'quizId': '1',
  'type': 'TRUE_FALSE',
  'questionText': '月 means moon',
  'options': ['true', 'false'],
  'correctAnswer': 'true',
  'explanation': '月 (ゲツ/つき) means moon',
  'points': 10,
  'orderIndex': 2,
  'createdAt': '2024-01-01T00:00:00.000Z',
  'meanings': [],
};

final tQuestionFillInBlank1Json = {
  'id': '5',
  'quizId': '2',
  'type': 'FILL_IN_BLANK',
  'questionText': 'What is the reading of 水?',
  'options': [],
  'correctAnswer': 'みず',
  'explanation': '水 is read as みず (mizu)',
  'points': 15,
  'orderIndex': 0,
  'createdAt': '2024-01-02T00:00:00.000Z',
  'meanings': [],
};

// For backwards compatibility
final tQuestionMultipleChoiceJson = tQuestionMultipleChoice1Json;

final tQuestionDrawingJson = {
  'id': '7',
  'quizId': '3',
  'type': 'DRAWING',
  'questionText': 'Draw the kanji for: sun, day',
  'options': [],
  'correctAnswer': '日',
  'explanation': 'Draw the kanji 日',
  'points': 20,
  'orderIndex': 0,
  'createdAt': '2024-01-03T00:00:00.000Z',
  'meanings': ['sun', 'day'],
};

final tQuizResultJson = {
  'id': '1',
  'userId': '1',
  'quizId': '1',
  'totalQuestions': 10,
  'correctAnswers': 8,
  'incorrectAnswers': 2,
  'skippedQuestions': 0,
  'totalPoints': 100,
  'earnedPoints': 80,
  'scorePercentage': 80.0,
  'timeSpent': 480,
  'isPassed': true,
  'answers': [],
  'completedAt': '2024-01-01T10:15:00.000Z',
  'createdAt': '2024-01-01T10:00:00.000Z',
};

final tQuizResult1Json = tQuizResultJson;

final tQuizResult2Json = {
  'id': '2',
  'userId': '1',
  'quizId': '2',
  'totalQuestions': 20,
  'correctAnswers': 13,
  'incorrectAnswers': 7,
  'skippedQuestions': 0,
  'totalPoints': 200,
  'earnedPoints': 130,
  'scorePercentage': 65.0,
  'timeSpent': 900,
  'isPassed': false,
  'answers': [],
  'completedAt': '2024-01-02T14:30:00.000Z',
  'createdAt': '2024-01-02T14:00:00.000Z',
};

// Create request data
final tCreateQuizData = {
  'title': 'New Quiz',
  'description': 'A new quiz for testing',
  'difficulty': 'EASY',
  'timeLimit': 600,
  'passingScore': 70,
};

final tCreateQuestionMultipleChoiceData = {
  'type': 'MULTIPLE_CHOICE',
  'questionText': 'What does 水 mean?',
  'options': ['water', 'fire', 'sun', 'moon'],
  'correctAnswer': 'water',
  'explanation': '水 means water',
  'points': 10,
};

final tCreateQuestionDrawingData = {
  'type': 'DRAWING',
  'questionText': 'Draw the kanji for: water',
  'correctAnswer': '水',
  'explanation': 'Draw the kanji 水',
  'points': 20,
  'meanings': ['water'],
};

// Submit quiz data
final tSubmitQuizData = {
  'answers': [
    {'questionId': '1', 'answer': 'sun'},
    {'questionId': '2', 'answer': 'ゲツ'},
  ],
};

// Query parameters
const tDifficulty = 'EASY';
const tIsPublished = true;
const tSearchQuery = 'JLPT';
const tLimit = 20;
const tOffset = 0;

// Error messages
const tQuizNotFoundError = 'Quiz not found';
const tQuestionNotFoundError = 'Question not found';
const tInvalidQuestionTypeError = 'Invalid question type';
const tInvalidAnswerError = 'Invalid answer format';
const tQuizNotPublishedError = 'Quiz is not published yet';
const tTimeExpiredError = 'Quiz time limit exceeded';
const tNetworkError = 'Network error occurred';
const tServerError = 'Server error occurred';
