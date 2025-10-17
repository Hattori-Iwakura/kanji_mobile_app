import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/quiz_repository.dart';
import 'quiz_list_event.dart';
import 'quiz_list_state.dart';

class QuizListBloc extends Bloc<QuizListEvent, QuizListState> {
  final QuizRepository repository;

  QuizListBloc({required this.repository}) : super(QuizListInitial()) {
    on<LoadQuizzesEvent>(_onLoadQuizzes);
    on<RefreshQuizzesEvent>(_onRefreshQuizzes);
    on<FilterChangedEvent>(_onFilterChanged);
  }

  Future<void> _onLoadQuizzes(
    LoadQuizzesEvent event,
    Emitter<QuizListState> emit,
  ) async {
    emit(QuizListLoading());
    try {
      final quizzes = await repository.getQuizzes(
        myQuizzes: event.myQuizzes,
        isPublic: event.publicOnly,
        category: event.category,
        difficulty: event.difficulty,
      );
      emit(QuizListLoaded(quizzes));
    } catch (e) {
      emit(QuizListError(e.toString()));
    }
  }

  Future<void> _onRefreshQuizzes(
    RefreshQuizzesEvent event,
    Emitter<QuizListState> emit,
  ) async {
    // Reload with current filters
    if (state is QuizListLoaded) {
      add(const LoadQuizzesEvent());
    }
  }

  Future<void> _onFilterChanged(
    FilterChangedEvent event,
    Emitter<QuizListState> emit,
  ) async {
    add(
      LoadQuizzesEvent(category: event.category, difficulty: event.difficulty),
    );
  }
}
