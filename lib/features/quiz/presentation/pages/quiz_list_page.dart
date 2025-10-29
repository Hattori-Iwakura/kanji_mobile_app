import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import 'quiz_detail_page.dart';
import 'create_quiz_page.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadQuizzes() {
    print('🟣 QuizListPage - _loadQuizzes called');
    final bloc = context.read<QuizBloc>();
    print('🟣 QuizListPage - QuizBloc instance: ${bloc.hashCode}');
    print('🟣 QuizListPage - Current state: ${bloc.state.runtimeType}');
    bloc.add(
      LoadQuizzesEvent(search: _searchQuery.isEmpty ? null : _searchQuery),
    );
    print('🟣 QuizListPage - LoadQuizzesEvent dispatched');
  }

  void _navigateToCreateQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateQuizPage()),
    );
    print('🟣 QuizListPage - back from CreateQuiz, result: $result');
    if (result == true) {
      _loadQuizzes();
    }
  }

  void _navigateToQuizDetail(int quizId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizDetailPage(quizId: quizId)),
    );
    print('🟣 QuizListPage - back from QuizDetail, result: $result');
    // Always reload when coming back, regardless of result
    _loadQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF071126),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF071126), Color(0xFF0B0F14)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Quizzes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search quizzes...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.tealAccent,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                  _loadQuizzes();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onSubmitted: (value) {
                        setState(() => _searchQuery = value);
                        _loadQuizzes();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Quiz list
                Expanded(
                  child: BlocConsumer<QuizBloc, QuizState>(
                    listener: (context, state) {
                      print(
                        '🟢 QuizListPage - listener - state: ${state.runtimeType}',
                      );
                      if (state is QuizError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${state.message}')),
                        );
                      }
                    },
                    builder: (context, state) {
                      print(
                        '🟢 QuizListPage - builder - state: ${state.runtimeType}',
                      );
                      if (state is QuizzesLoaded) {
                        print(
                          '🟢 QuizListPage - QuizzesLoaded - quizzes.length: ${state.quizzes.length}',
                        );
                      }

                      if (state is QuizLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.tealAccent,
                          ),
                        );
                      }

                      if (state is QuizzesLoaded) {
                        if (state.quizzes.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.quiz_outlined,
                                  size: 80,
                                  color: Colors.white24,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No quizzes yet'
                                      : 'No quizzes found',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Create your first quiz to get started',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => _navigateToCreateQuiz(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.tealAccent,
                                      foregroundColor: const Color(0xFF071126),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text(
                                      'Create Quiz',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          color: Colors.tealAccent,
                          backgroundColor: const Color(0xFF0B0F14),
                          onRefresh: () async => _loadQuizzes(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.quizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = state.quizzes[index];
                              final questionCount = quiz.questions?.length ?? 0;
                              final totalPoints =
                                  quiz.questions?.fold<int>(
                                    0,
                                    (sum, q) => sum + q.points,
                                  ) ??
                                  0;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.tealAccent.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _navigateToQuizDetail(quiz.id),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: Colors.tealAccent
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '$questionCount',
                                                    style: const TextStyle(
                                                      color: Colors.tealAccent,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      quiz.title,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: quiz.isPublic
                                                                ? Colors.green
                                                                      .withOpacity(
                                                                        0.2,
                                                                      )
                                                                : Colors.grey
                                                                      .withOpacity(
                                                                        0.2,
                                                                      ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            quiz.isPublic
                                                                ? 'Public'
                                                                : 'Private',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  quiz.isPublic
                                                                  ? Colors
                                                                        .greenAccent
                                                                  : Colors
                                                                        .white54,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Icon(
                                                          Icons.star_rounded,
                                                          size: 16,
                                                          color: Colors
                                                              .amber
                                                              .shade400,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          '$totalPoints pts',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .white70,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(
                                                Icons.chevron_right,
                                                color: Colors.tealAccent,
                                                size: 28,
                                              ),
                                            ],
                                          ),
                                          if (quiz.description != null) ...[
                                            const SizedBox(height: 12),
                                            Text(
                                              quiz.description!,
                                              style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.quiz, size: 64, color: Colors.white38),
                            const SizedBox(height: 16),
                            const Text(
                              'Tap + to create a quiz',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ), // Expanded
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateQuiz,
        backgroundColor: Colors.tealAccent,
        foregroundColor: const Color(0xFF071126),
        icon: const Icon(Icons.add),
        label: const Text(
          'New Quiz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
