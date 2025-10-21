import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/network/api_client.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../widgets/app_drawer.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';

class UserLandingPage extends StatefulWidget {
  const UserLandingPage({super.key});

  @override
  State<UserLandingPage> createState() => _UserLandingPageState();
}

class _UserLandingPageState extends State<UserLandingPage> {
  final ApiClient _apiClient = di.sl<ApiClient>();

  bool _isLoading = true;
  Map<String, dynamic> _userStats = {};
  List<dynamic> _recentKanji = [];
  List<dynamic> _myLists = [];
  List<dynamic> _myDecks = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch user's kanji lists
      final listsResponse = await _apiClient.get('/kanji-lists');
      print('Lists Response: ${listsResponse.data}'); // DEBUG
      final listsData = listsResponse.data;

      // Handle both Map and direct array responses
      if (listsData is Map<String, dynamic>) {
        _myLists = (listsData['data'] as List?) ?? [];
      } else if (listsData is List) {
        _myLists = listsData;
      } else {
        _myLists = [];
      }

      // Fetch user's flashcard decks
      final decksResponse = await _apiClient.get('/flashcard-decks');
      print('Decks Response: ${decksResponse.data}'); // DEBUG
      final decksData = decksResponse.data;

      // Handle both Map and direct array responses
      if (decksData is Map<String, dynamic>) {
        _myDecks = (decksData['data'] as List?) ?? [];
      } else if (decksData is List) {
        _myDecks = decksData;
      } else {
        _myDecks = [];
      }

      // Fetch recent kanji (using search with limit)
      final kanjiResponse = await _apiClient.get('/kanji?limit=5');
      print('Kanji Response: ${kanjiResponse.data}'); // DEBUG
      final kanjiData = kanjiResponse.data;

      // Handle both Map and direct array responses
      if (kanjiData is Map<String, dynamic>) {
        _recentKanji = (kanjiData['data'] as List?) ?? [];
      } else if (kanjiData is List) {
        _recentKanji = kanjiData;
      } else {
        _recentKanji = [];
      }

      // Calculate user statistics
      int totalKanjiInLists = 0;
      for (var list in _myLists) {
        final kanjiList = (list['kanji'] as List?) ?? [];
        totalKanjiInLists += kanjiList.length;
      }

      int totalFlashcards = 0;
      for (var deck in _myDecks) {
        final cards = (deck['cards'] as List?) ?? [];
        totalFlashcards += cards.length;
      }

      setState(() {
        _userStats = {
          'totalLists': _myLists.length,
          'totalKanjiInLists': totalKanjiInLists,
          'totalDecks': _myDecks.length,
          'totalFlashcards': totalFlashcards,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Learning'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Navigate based on index
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.kanjiDictionary,
              );
              break;
            case 2:
              Navigator.pushReplacementNamed(context, AppRoutes.kanjiLists);
              break;
            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.flashcardDecks);
              break;
            case 4:
              Navigator.pushReplacementNamed(context, AppRoutes.quizList);
              break;
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            _buildWelcomeBanner(),
            const SizedBox(height: 24),

            // Learning Progress
            _buildProgressSection(),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Recent Kanji
            if (_recentKanji.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Kanji',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.kanjiDictionary),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRecentKanjiSection(),
              const SizedBox(height: 24),
            ],

            // My Collections
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Collections',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.kanjiLists),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMyCollections(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String username = 'User';
        if (state is Authenticated) {
          username = state.user.username;
        }

        final hour = DateTime.now().hour;
        String greeting = 'Good morning';
        if (hour >= 12 && hour < 17) {
          greeting = 'Good afternoon';
        } else if (hour >= 17) {
          greeting = 'Good evening';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, $username!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ready to continue your kanji journey?',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'My Lists',
              _userStats['totalLists']?.toString() ?? '0',
              Icons.list,
              Colors.green,
            ),
            _buildStatCard(
              'Kanji Learned',
              _userStats['totalKanjiInLists']?.toString() ?? '0',
              Icons.book,
              Colors.orange,
            ),
            _buildStatCard(
              'Flashcard Decks',
              _userStats['totalDecks']?.toString() ?? '0',
              Icons.style,
              Colors.purple,
            ),
            _buildStatCard(
              'Total Cards',
              _userStats['totalFlashcards']?.toString() ?? '0',
              Icons.credit_card,
              Colors.pink,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildActionCard(
          'Practice',
          Icons.style_outlined,
          Colors.purple,
          () => Navigator.pushNamed(context, AppRoutes.flashcardDecks),
        ),
        _buildActionCard(
          'Take Quiz',
          Icons.quiz_outlined,
          Colors.red,
          () => Navigator.pushNamed(context, AppRoutes.quizList),
        ),
        _buildActionCard(
          'Dictionary',
          Icons.book_outlined,
          Colors.blue,
          () => Navigator.pushNamed(context, AppRoutes.kanjiDictionary),
        ),
        _buildActionCard(
          'Recognition',
          Icons.draw_outlined,
          Colors.orange,
          () => Navigator.pushNamed(context, AppRoutes.search),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentKanjiSection() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recentKanji.length,
        itemBuilder: (context, index) {
          final kanji = _recentKanji[index];
          return Card(
            margin: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.kanjiDetail,
                  arguments: kanji['id'],
                );
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      kanji['character'] ?? '',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kanji['meanings']?.toString().split(',')[0] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyCollections() {
    if (_myLists.isEmpty && _myDecks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.collections_bookmark_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No collections yet',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first kanji list or flashcard deck',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.kanjiLists),
                icon: const Icon(Icons.add),
                label: const Text('Create List'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Lists
        if (_myLists.isNotEmpty) ...[
          ..._myLists.take(3).map((list) {
            final kanjiCount = (list['kanji'] as List?)?.length ?? 0;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.list, color: Colors.green),
                ),
                title: Text(
                  list['name'] ?? 'Untitled List',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$kanjiCount kanji'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.kanjiListDetail,
                    arguments: list['id'],
                  );
                },
              ),
            );
          }),
        ],
        // Decks
        if (_myDecks.isNotEmpty) ...[
          ..._myDecks.take(3).map((deck) {
            final cardCount = (deck['cards'] as List?)?.length ?? 0;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.style, color: Colors.purple),
                ),
                title: Text(
                  deck['name'] ?? 'Untitled Deck',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$cardCount cards'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.flashcardDeckDetail,
                    arguments: deck['id'],
                  );
                },
              ),
            );
          }),
        ],
      ],
    );
  }
}
