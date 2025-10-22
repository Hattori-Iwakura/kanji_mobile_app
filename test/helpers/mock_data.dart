/// Mock data for testing
library;

const mockUserJson = {
  'id': '1',
  'email': 'test@example.com',
  'name': 'Test User',
  'role': 'USER',
  'createdAt': '2024-01-01T00:00:00.000Z',
  'updatedAt': '2024-01-01T00:00:00.000Z',
};

const mockAdminUserJson = {
  'id': '2',
  'email': 'admin@example.com',
  'name': 'Admin User',
  'role': 'ADMIN',
  'createdAt': '2024-01-01T00:00:00.000Z',
  'updatedAt': '2024-01-01T00:00:00.000Z',
};

const mockKanjiJson = {
  'id': '1',
  'character': '日',
  'meanings': ['sun', 'day'],
  'onReading': ['ニチ', 'ジツ'],
  'kunReading': ['ひ', 'か'],
  'jlptLevel': 'N5',
  'grade': 1,
  'strokeCount': 4,
  'frequency': 1,
  'strokeOrder': 'assets/strokes/kanji_001.json',
};

const mockKanjiListJson = [
  {
    'id': '1',
    'character': '日',
    'meanings': ['sun', 'day'],
    'onReading': ['ニチ', 'ジツ'],
    'kunReading': ['ひ', 'か'],
    'jlptLevel': 'N5',
    'grade': 1,
    'strokeCount': 4,
    'frequency': 1,
  },
  {
    'id': '2',
    'character': '月',
    'meanings': ['moon', 'month'],
    'onReading': ['ゲツ', 'ガツ'],
    'kunReading': ['つき'],
    'jlptLevel': 'N5',
    'grade': 1,
    'strokeCount': 4,
    'frequency': 2,
  },
  {
    'id': '3',
    'character': '火',
    'meanings': ['fire'],
    'onReading': ['カ'],
    'kunReading': ['ひ', 'ほ'],
    'jlptLevel': 'N5',
    'grade': 1,
    'strokeCount': 4,
    'frequency': 3,
  },
];

const mockFlashcardDeckJson = {
  'id': '1',
  'name': 'JLPT N5 Kanji',
  'description': 'Basic kanji for beginners',
  'cardCount': 50,
  'userId': '1',
  'createdAt': '2024-01-01T00:00:00.000Z',
};

const mockFlashcardJson = {
  'id': '1',
  'deckId': '1',
  'kanjiId': '1',
  'front': '日',
  'back': 'sun, day\nニチ, ジツ\nひ, か',
  'interval': 1,
  'repetitions': 0,
  'easeFactor': 2.5,
  'nextReviewDate': '2024-01-02T00:00:00.000Z',
};

const mockQuizJson = {
  'id': '1',
  'title': 'JLPT N5 Practice Quiz',
  'description': 'Test your N5 knowledge',
  'difficulty': 'BEGINNER',
  'questionCount': 10,
  'timeLimit': 600,
  'createdAt': '2024-01-01T00:00:00.000Z',
};

const mockQuestionJson = {
  'id': '1',
  'quizId': '1',
  'type': 'MULTIPLE_CHOICE',
  'questionText': 'What does 日 mean?',
  'options': ['sun', 'moon', 'fire', 'water'],
  'correctAnswer': 'sun',
  'order': 1,
};

const mockQuizResultJson = {
  'id': '1',
  'quizId': '1',
  'userId': '1',
  'score': 8,
  'totalQuestions': 10,
  'timeSpent': 300,
  'completedAt': '2024-01-01T00:10:00.000Z',
};

// Auth responses
const mockLoginSuccessResponse = {
  'token': 'mock_jwt_token_12345',
  'user': mockUserJson,
};

const mockRegisterSuccessResponse = {
  'token': 'mock_jwt_token_67890',
  'user': mockUserJson,
};

const mockLoginErrorResponse = {
  'statusCode': 401,
  'message': 'Invalid credentials',
  'error': 'Unauthorized',
};

const mockRegisterEmailExistsResponse = {
  'statusCode': 409,
  'message': 'Email already exists',
  'error': 'Conflict',
};

const mockServerErrorResponse = {
  'statusCode': 500,
  'message': 'Internal server error',
  'error': 'Internal Server Error',
};

// Token
const mockValidToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJ0ZXN0QGV4YW1wbGUuY29tIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
const mockExpiredToken = 'expired_token';

// Validation errors
const invalidEmailError = 'Invalid email format';
const emptyFieldError = 'This field cannot be empty';
const passwordTooShortError = 'Password must be at least 6 characters';
