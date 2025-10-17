# Quiz Module - Complete Implementation Summary

## ✅ Backend Complete (12 Endpoints)

### Database Schema
- **4 Models**: Quiz, Question, QuizAttempt, QuizAnswer
- **2 Enums**: QuizQuestionType (MULTIPLE_CHOICE, FILL_IN_BLANK, DRAWING), QuizDifficulty (BEGINNER, INTERMEDIATE, ADVANCED, EXPERT)
- **Migration Applied**: `20251017064606_add_quiz_module`

### API Endpoints
1. POST /api/quiz - Create quiz
2. GET /api/quiz - List quizzes (filters: my_quizzes, public, category, difficulty)
3. GET /api/quiz/:id - Get quiz detail
4. PUT /api/quiz/:id - Update quiz
5. DELETE /api/quiz/:id - Delete quiz
6. POST /api/quiz/:id/question - Add question
7. DELETE /api/quiz/question/:id - Delete question
8. POST /api/quiz/start - Start quiz attempt
9. POST /api/quiz/answer - Submit answer
10. GET /api/quiz/attempt/:id - Get attempt results
11. GET /api/quiz/my-attempts - Get user attempts
12. GET /api/quiz/:id/statistics - Get quiz statistics

### Files Created (Backend)
```
kanji-web-be/src/modules/quiz/
├── dto/
│   ├── create-quiz.dto.ts
│   ├── create-question.dto.ts
│   ├── start-quiz.dto.ts
│   ├── submit-answer.dto.ts
│   ├── update-quiz.dto.ts
│   └── index.ts
├── quiz.controller.ts (143 lines)
├── quiz.service.ts (186 lines)
├── quiz.repository.ts (329 lines)
└── quiz.module.ts
```

---

## 🚧 Flutter In Progress

### ✅ Domain Layer Complete
Created entities with Equatable:
```
lib/features/quiz/domain/entities/
├── quiz_enums.dart - QuizQuestionType, QuizDifficulty enums with extensions
├── question.dart - Question entity
├── quiz.dart - Quiz entity with totalPoints, questionCount getters
├── quiz_answer.dart - QuizAnswer entity
└── quiz_attempt.dart - QuizAttempt with scorePercentage, correctAnswersCount getters
```

### ✅ Data Models Complete
Created JSON serialization models:
```
lib/features/quiz/data/models/
├── question_model.dart - fromJson/toJson for Question
├── quiz_model.dart - fromJson/toJson for Quiz
├── quiz_answer_model.dart - fromJson/toJson for QuizAnswer
└── quiz_attempt_model.dart - fromJson/toJson for QuizAttempt
```

### 📋 TODO: Data Layer (Remote Data Source)
Create API client methods:
```dart
// lib/features/quiz/data/datasources/quiz_remote_datasource.dart
abstract class QuizRemoteDataSource {
  Future<List<QuizModel>> getQuizzes({bool? myQuizzes, bool? isPublic, String? category, String? difficulty});
  Future<QuizModel> getQuizById(int quizId);
  Future<QuizModel> createQuiz(Map<String, dynamic> data);
  Future<QuizModel> updateQuiz(int quizId, Map<String, dynamic> data);
  Future<void> deleteQuiz(int quizId);
  
  Future<QuestionModel> addQuestion(int quizId, Map<String, dynamic> data);
  Future<void> deleteQuestion(int questionId);
  
  Future<QuizAttemptModel> startQuiz(int quizId);
  Future<QuizAnswerModel> submitAnswer(Map<String, dynamic> data);
  Future<QuizAttemptModel> getAttemptResults(int attemptId);
  Future<List<QuizAttemptModel>> getUserAttempts({int? quizId});
  Future<Map<String, dynamic>> getQuizStatistics(int quizId);
}

// Implementation using ApiClient (similar to KanjiRemoteDataSource)
class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final ApiClient apiClient;
  
  @override
  Future<List<QuizModel>> getQuizzes(...) async {
    final response = await apiClient.get('/quiz', queryParameters: {...});
    final data = responseData['data'] ?? responseData;
    return (data as List).map((q) => QuizModel.fromJson(q)).toList();
  }
  // ... implement all methods
}
```

### 📋 TODO: Repository Implementation
```dart
// lib/features/quiz/domain/repositories/quiz_repository.dart
abstract class QuizRepository {
  Future<Either<Failure, List<Quiz>>> getQuizzes(...);
  Future<Either<Failure, Quiz>> getQuizById(int quizId);
  Future<Either<Failure, Quiz>> createQuiz(CreateQuizParams params);
  // ... all methods returning Either<Failure, T>
}

// lib/features/quiz/data/repositories/quiz_repository_impl.dart
class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;
  
  @override
  Future<Either<Failure, List<Quiz>>> getQuizzes(...) async {
    try {
      final quizzes = await remoteDataSource.getQuizzes(...);
      return Right(quizzes.map((q) => q.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### 📋 TODO: BLoC Layer (4 BLoCs)

#### 1. QuizListBloc - Browse and search quizzes
```dart
// Events: LoadQuizzes, FilterChanged, RefreshQuizzes
// States: QuizListInitial, QuizListLoading, QuizListLoaded, QuizListError

class LoadQuizzesEvent extends QuizListEvent {
  final bool myQuizzes;
  final bool publicOnly;
  final String? category;
  final QuizDifficulty? difficulty;
}
```

#### 2. QuizDetailBloc - View quiz details
```dart
// Events: LoadQuizDetail, DeleteQuiz
// States: QuizDetailInitial, QuizDetailLoading, QuizDetailLoaded, QuizDetailError
```

#### 3. QuizSessionBloc - Active quiz taking
```dart
// Events: StartQuiz, SubmitAnswer, NextQuestion, PreviousQuestion, FinishQuiz
// States: QuizSessionInitial, QuizSessionInProgress, QuestionAnswered, QuizSessionCompleted, QuizSessionError

class QuizSessionState {
  final QuizAttempt attempt;
  final int currentQuestionIndex;
  final Map<int, String> userAnswers; // questionId -> answer
  final Map<int, int> questionTimes; // questionId -> seconds spent
  final DateTime? questionStartTime;
}
```

#### 4. QuizResultBloc - View results
```dart
// Events: LoadQuizResult
// States: QuizResultInitial, QuizResultLoading, QuizResultLoaded, QuizResultError
```

### 📋 TODO: UI Pages (5 Pages)

#### 1. QuizListPage - Browse quizzes
```dart
// Features:
// - Tab bar: My Quizzes | Public Quizzes
// - Filter chips: Category, Difficulty
// - Quiz cards showing: title, description, difficulty badge, question count, attempts count
// - FAB: Create new quiz (navigates to CreateQuizPage)
// - Card tap: Navigate to QuizDetailPage

Scaffold(
  appBar: AppBar(
    title: Text('Quizzes'),
    bottom: TabBar(tabs: [Tab(text: 'My Quizzes'), Tab(text: 'Public')]),
  ),
  body: TabBarView(children: [
    // My quizzes list
    // Public quizzes list with filters
  ]),
  floatingActionButton: FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: () => Navigator.push(context, CreateQuizPage.route()),
  ),
)
```

#### 2. QuizDetailPage - Preview quiz
```dart
// Features:
// - Quiz header: title, description, difficulty, category, tags
// - Statistics: X questions, Y total points, Z attempts
// - Question list (preview, no answers shown)
// - Action buttons:
//   - Start Quiz (if user can take)
//   - Edit Quiz (if user is owner)
//   - View Statistics (if owner)
//   - Delete Quiz (if owner with confirmation)

Column(children: [
  // Header card with title, description
  // Stats row
  // Questions list
  ElevatedButton(
    onPressed: () {
      context.read<QuizSessionBloc>().add(StartQuizEvent(quizId));
      Navigator.push(context, QuizSessionPage.route(quizId));
    },
    child: Text('Start Quiz'),
  ),
])
```

#### 3. QuizSessionPage - Take quiz
```dart
// Features:
// - Progress indicator: Question 1/10
// - Timer per question (if time_limit set)
// - Question renderer based on type:
//   - MultipleChoiceWidget (4 option buttons)
//   - FillInBlankWidget (TextField)
//   - DrawingQuestionWidget (canvas + submit button)
// - Navigation: Previous/Next buttons
// - Auto-submit on last question
// - Confirmation dialog before exit

class QuizSessionPage extends StatefulWidget {
  Widget build(context) {
    return BlocBuilder<QuizSessionBloc, QuizSessionState>(
      builder: (context, state) {
        if (state is QuizSessionInProgress) {
          final question = state.currentQuestion;
          return Scaffold(
            appBar: AppBar(
              title: Text('Question ${state.currentQuestionIndex + 1}/${state.totalQuestions}'),
            ),
            body: Column(children: [
              LinearProgressIndicator(value: state.progress),
              if (question.timeLimit != null) TimerWidget(duration: question.timeLimit!),
              _buildQuestionWidget(question),
              Row(children: [
                if (state.currentQuestionIndex > 0)
                  TextButton(child: Text('Previous'), onPressed: _goPrevious),
                Spacer(),
                ElevatedButton(
                  child: Text(state.isLastQuestion ? 'Finish' : 'Next'),
                  onPressed: _submitAndNext,
                ),
              ]),
            ]),
          );
        }
      },
    );
  }
  
  Widget _buildQuestionWidget(Question question) {
    switch (question.type) {
      case QuizQuestionType.multipleChoice:
        return MultipleChoiceWidget(question: question, onAnswerSelected: _onAnswerSelected);
      case QuizQuestionType.fillInBlank:
        return FillInBlankWidget(question: question, onAnswerChanged: _onAnswerChanged);
      case QuizQuestionType.drawing:
        return DrawingQuestionWidget(question: question, onAnswerSubmitted: _onDrawingSubmitted);
    }
  }
}
```

##### Question Widgets:
```dart
// widgets/multiple_choice_widget.dart
class MultipleChoiceWidget extends StatefulWidget {
  final Question question;
  final Function(String) onAnswerSelected;
  
  Widget build(context) {
    return Column(children: [
      Text(question.question, style: Theme.of(context).textTheme.headlineSmall),
      ...question.options!.entries.map((entry) => 
        RadioListTile<String>(
          title: Text('${entry.key}. ${entry.value}'),
          value: entry.key,
          groupValue: _selectedAnswer,
          onChanged: (value) {
            setState(() => _selectedAnswer = value);
            onAnswerSelected(value!);
          },
        ),
      ),
    ]);
  }
}

// widgets/fill_in_blank_widget.dart
class FillInBlankWidget extends StatefulWidget {
  final Question question;
  final Function(String) onAnswerChanged;
  
  Widget build(context) {
    return Column(children: [
      Text(question.question),
      if (question.metadata?['hint'] != null)
        Text('Hint: ${question.metadata!['hint']}', style: TextStyle(fontStyle: FontStyle.italic)),
      TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: 'Your answer'),
        onChanged: onAnswerChanged,
      ),
    ]);
  }
}

// widgets/drawing_question_widget.dart
class DrawingQuestionWidget extends StatefulWidget {
  final Question question;
  final Function(String, Map<String, dynamic>) onAnswerSubmitted;
  
  Widget build(context) {
    return Column(children: [
      Text(question.question),
      if (question.metadata?['hint'] != null)
        Text('Hint: ${question.metadata!['hint']}'),
      Expanded(
        child: DrawingCanvas(
          onStrokeAdded: () => setState(() => _hasDrawing = true),
        ),
      ),
      Row(children: [
        TextButton(child: Text('Clear'), onPressed: _clearCanvas),
        ElevatedButton(
          child: Text('Recognize'),
          onPressed: _hasDrawing ? _recognizeDrawing : null,
        ),
      ]),
    ]);
  }
  
  Future<void> _recognizeDrawing() async {
    final imageBytes = await _canvas.toImage();
    // Call recognition API
    final response = await apiClient.post('/kanji-recognition/predict', 
      data: {'image': base64Encode(imageBytes)});
    final predictions = response['predictions'];
    final topPrediction = predictions[0];
    
    onAnswerSubmitted(
      topPrediction['character'],
      {
        'confidence': topPrediction['probability'],
        'predictions': predictions,
      },
    );
  }
}
```

#### 4. QuizResultPage - Show results
```dart
// Features:
// - Score card: X/Y points (Z%)
// - Time taken
// - Correct/Wrong/Unanswered counts
// - Review section: List of questions with:
//   - Question text
//   - User's answer
//   - Correct answer
//   - Explanation (if available)
//   - ✓ or ✗ indicator
// - Action buttons: Retake Quiz, Back to List

Scaffold(
  appBar: AppBar(title: Text('Quiz Results')),
  body: ListView(children: [
    // Score card
    Card(child: Column(children: [
      Text('${attempt.score}/${attempt.maxScore}', style: Theme.of(context).textTheme.displayLarge),
      Text('${attempt.scorePercentage.toStringAsFixed(1)}%'),
      Text('Time: ${_formatDuration(attempt.timeSpent)}'),
      Row(children: [
        Text('✓ ${attempt.correctAnswersCount}'),
        Text('✗ ${attempt.wrongAnswersCount}'),
      ]),
    ])),
    
    // Questions review
    Text('Review', style: Theme.of(context).textTheme.headlineSmall),
    ...attempt.answers.map((answer) {
      final question = _getQuestion(answer.questionId);
      return Card(child: ListTile(
        leading: Icon(answer.isCorrect ? Icons.check_circle : Icons.cancel, 
                     color: answer.isCorrect ? Colors.green : Colors.red),
        title: Text(question.question),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your answer: ${answer.userAnswer}'),
          if (!answer.isCorrect)
            Text('Correct: ${question.correctAnswer}', style: TextStyle(color: Colors.green)),
          if (question.explanation != null)
            Text('Explanation: ${question.explanation}'),
        ]),
      ));
    }),
    
    // Actions
    Row(children: [
      TextButton(child: Text('Back to List'), onPressed: () => Navigator.pop(context)),
      ElevatedButton(child: Text('Retake Quiz'), onPressed: _retakeQuiz),
    ]),
  ]),
)
```

#### 5. CreateQuizPage - Create/edit quizzes
```dart
// Features:
// - Form fields: title, description, difficulty, category, tags, is_public
// - Questions section:
//   - Add Question button
//   - List of added questions (reorderable)
//   - Edit/Delete buttons per question
// - Add Question Dialog:
//   - Question type selector
//   - Dynamic form based on type:
//     - Multiple Choice: question + 4 options + correct option
//     - Fill in Blank: question + answer + hint
//     - Drawing: question + expected kanji + hint + stroke count
//   - Points, time limit, explanation fields

Form(child: Column(children: [
  TextFormField(decoration: InputDecoration(labelText: 'Title')),
  TextFormField(decoration: InputDecoration(labelText: 'Description'), maxLines: 3),
  DropdownButtonFormField<QuizDifficulty>(
    decoration: InputDecoration(labelText: 'Difficulty'),
    items: QuizDifficulty.values.map((d) => DropdownMenuItem(value: d, child: Text(d.label))).toList(),
  ),
  // ... other fields
  
  Text('Questions', style: Theme.of(context).textTheme.titleLarge),
  ReorderableListView(
    children: _questions.map((q) => QuestionCard(key: ValueKey(q.id), question: q)).toList(),
    onReorder: _reorderQuestions,
  ),
  
  ElevatedButton(
    child: Text('Add Question'),
    onPressed: _showAddQuestionDialog,
  ),
  
  ElevatedButton(
    child: Text('Create Quiz'),
    onPressed: _createQuiz,
  ),
]))
```

### 📋 TODO: Integration with MainHomePage

Add Quiz tab to bottom navigation:
```dart
// lib/core/widgets/main_home_page.dart
// Line ~80: Add to BottomNavigationBarItem list
BottomNavigationBarItem(
  icon: Icon(Icons.quiz_outlined),
  activeIcon: Icon(Icons.quiz),
  label: 'Quiz',
),

// Line ~90: Add to IndexedStack children
const QuizListPage(),
```

### 📋 TODO: Dependency Injection

Register in `injection_container.dart`:
```dart
// Data sources
sl.registerLazySingleton<QuizRemoteDataSource>(
  () => QuizRemoteDataSourceImpl(apiClient: sl()),
);

// Repositories
sl.registerLazySingleton<QuizRepository>(
  () => QuizRepositoryImpl(remoteDataSource: sl()),
);

// BLoCs
sl.registerFactory(() => QuizListBloc(repository: sl()));
sl.registerFactory(() => QuizDetailBloc(repository: sl()));
sl.registerFactory(() => QuizSessionBloc(repository: sl()));
sl.registerFactory(() => QuizResultBloc(repository: sl()));
```

### 📋 TODO: Routing

Add to `main.dart` routes:
```dart
'/quiz': (context) => const QuizListPage(),
'/quiz-detail': (context) => const QuizDetailPage(),
'/quiz-session': (context) => const QuizSessionPage(),
'/quiz-result': (context) => const QuizResultPage(),
'/quiz-create': (context) => const CreateQuizPage(),
```

---

## Implementation Priority

### Phase 1: Core Functionality (MVP)
1. ✅ Backend API (COMPLETE)
2. ✅ Domain entities (COMPLETE)
3. ✅ Data models (COMPLETE)
4. 🔲 Remote data source
5. 🔲 Repository implementation
6. 🔲 QuizListBloc + QuizListPage (browse quizzes)
7. 🔲 QuizDetailBloc + QuizDetailPage (view quiz)
8. 🔲 QuizSessionBloc + QuizSessionPage (take quiz)
   - Start with Multiple Choice only
9. 🔲 QuizResultBloc + QuizResultPage (view results)

### Phase 2: Question Types
10. 🔲 Fill in Blank widget
11. 🔲 Drawing widget with Kanji Recognition integration

### Phase 3: Quiz Creation
12. 🔲 CreateQuizPage (create/edit quizzes)
13. 🔲 Add/Edit Question dialogs

### Phase 4: Polish
14. 🔲 Bottom navigation integration
15. 🔲 Drawer menu integration
16. 🔲 Error handling and loading states
17. 🔲 UI animations and transitions

---

## Drawing Question Implementation Details

### Canvas Widget
Reuse or adapt from existing recognition feature:
```dart
// Check if exists in lib/features/kanji/presentation/widgets/drawing_canvas.dart
// If not, create simplified version:

class DrawingCanvas extends StatefulWidget {
  final VoidCallback? onStrokeAdded;
  
  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<Offset?> _points = [];
  
  Widget build(context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _points.add(details.localPosition);
        });
        widget.onStrokeAdded?.call();
      },
      onPanEnd: (details) {
        _points.add(null); // Stroke separator
      },
      child: CustomPaint(
        painter: DrawingPainter(_points),
        child: Container(),
      ),
    );
  }
  
  Future<Uint8List> toImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    DrawingPainter(_points).paint(canvas, Size(300, 300));
    final picture = recorder.endRecording();
    final img = await picture.toImage(300, 300);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
  
  void clear() {
    setState(() => _points.clear());
  }
}
```

### Recognition API Integration
```dart
// In DrawingQuestionWidget
Future<Map<String, dynamic>> _recognizeKanji(Uint8List imageBytes) async {
  final response = await apiClient.post(
    '/kanji-recognition/predict',
    data: {
      'image': base64Encode(imageBytes),
    },
  );
  
  return response['data']; // {predictions: [{character, probability}, ...]}
}
```

---

## File Structure Summary

```
kanji_flutter/lib/features/quiz/
├── domain/
│   ├── entities/
│   │   ├── quiz_enums.dart ✅
│   │   ├── question.dart ✅
│   │   ├── quiz.dart ✅
│   │   ├── quiz_answer.dart ✅
│   │   └── quiz_attempt.dart ✅
│   └── repositories/
│       └── quiz_repository.dart 🔲
├── data/
│   ├── models/
│   │   ├── question_model.dart ✅
│   │   ├── quiz_model.dart ✅
│   │   ├── quiz_answer_model.dart ✅
│   │   └── quiz_attempt_model.dart ✅
│   ├── datasources/
│   │   └── quiz_remote_datasource.dart 🔲
│   └── repositories/
│       └── quiz_repository_impl.dart 🔲
└── presentation/
    ├── bloc/
    │   ├── quiz_list/ 🔲
    │   ├── quiz_detail/ 🔲
    │   ├── quiz_session/ 🔲
    │   └── quiz_result/ 🔲
    ├── pages/
    │   ├── quiz_list_page.dart 🔲
    │   ├── quiz_detail_page.dart 🔲
    │   ├── quiz_session_page.dart 🔲
    │   ├── quiz_result_page.dart 🔲
    │   └── create_quiz_page.dart 🔲
    └── widgets/
        ├── multiple_choice_widget.dart 🔲
        ├── fill_in_blank_widget.dart 🔲
        ├── drawing_question_widget.dart 🔲
        ├── drawing_canvas.dart 🔲
        ├── quiz_card.dart 🔲
        ├── difficulty_badge.dart 🔲
        └── timer_widget.dart 🔲
```

✅ = Complete (9 files)
🔲 = Todo (24 files)

---

## Total Endpoints in System

After adding Quiz module:
- Auth: 4 endpoints
- User: 2 endpoints
- Kanji: 19 endpoints
- Flashcard: 15 endpoints
- Recognition: 1 endpoint
- AI: 2 endpoints
- **Quiz: 12 endpoints** ← NEW

**Total: 55 endpoints**

---

## Next Steps to Complete

1. **Implement QuizRemoteDataSource** - API calls with proper error handling and response parsing
2. **Implement QuizRepository** - Error handling with Either<Failure, T>
3. **Implement QuizListBloc** - Browse and filter quizzes
4. **Create QuizListPage** - UI with tabs and filters
5. **Implement QuizDetailBloc** - Load quiz details
6. **Create QuizDetailPage** - Quiz preview with start button
7. **Implement QuizSessionBloc** - Complex state management for active quiz
8. **Create QuizSessionPage** - Question navigation and rendering
9. **Create Question Widgets** - MultipleChoice, FillInBlank, Drawing
10. **Implement QuizResultBloc** - Load and display results
11. **Create QuizResultPage** - Score display and review
12. **Add to MainHomePage** - Bottom navigation integration
13. **Register dependencies** - Injection container
14. **Testing** - Unit tests for BLoCs, widget tests for pages

Would you like me to continue with implementing the remaining Flutter files?
