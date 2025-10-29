import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../features/flashcard/presentation/bloc/flashcard_bloc.dart';
import '../../../features/flashcard/presentation/pages/flashcard_deck_list_page.dart';
import '../../../features/kanji/presentation/pages/kanji_list_page.dart';
import '../../../features/kanji_table/presentation/pages/kanji_table_list_page.dart';
import '../../../features/kanji_table/presentation/bloc/kanji_table_bloc.dart';
import '../../../features/quiz/presentation/bloc/quiz_bloc.dart';
import '../../../features/quiz/presentation/pages/quiz_list_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../../../injection_container.dart';
import '../widgets/main_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is Authenticated
            ? authState.user.name
            : 'học viên';

        final isAdmin =
            authState is Authenticated && authState.user.role == 'ADMIN';

        return Scaffold(
          extendBody: true,
          drawer: const MainDrawer(),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // Top bar
                      Row(
                        children: [
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(Icons.menu, size: 28),
                              onPressed: () => Scaffold.of(ctx).openDrawer(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Xin chào, $userName!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProfilePage(apiClient: sl<ApiClient>()),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white10,
                              child: Icon(Icons.person, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Main content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bắt đầu học ngay',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Horizontal scrolling cards
                              SizedBox(
                                height: 160,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    // Admin Dashboard - only show for admin users
                                    if (isAdmin)
                                      _fancyCard(
                                        context,
                                        'Admin Dashboard',
                                        Icons.admin_panel_settings,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.deepPurpleAccent.withOpacity(
                                              0.2,
                                            ),
                                            Colors.purpleAccent.withOpacity(
                                              0.1,
                                            ),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        iconColor: Colors.deepPurpleAccent,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  AdminDashboardPage(
                                                    apiClient: sl<ApiClient>(),
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    _fancyCard(
                                      context,
                                      'Học Kanji',
                                      Icons.menu_book,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const KanjiListPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    _fancyCard(
                                      context,
                                      'Kanji Tables',
                                      Icons.table_chart,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider(
                                              create: (_) =>
                                                  sl<KanjiTableBloc>(),
                                              child: const KanjiTableListPage(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _fancyCard(
                                      context,
                                      'Flashcards',
                                      Icons.style,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: context
                                                  .read<FlashcardBloc>(),
                                              child:
                                                  const FlashcardDeckListPage(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _fancyCard(
                                      context,
                                      'Quiz',
                                      Icons.quiz,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: context.read<QuizBloc>(),
                                              child: const QuizListPage(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Grid of features
                              GridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                children: List.generate(4, (index) {
                                  final titles = [
                                    'JLPT Tables',
                                    'Lịch sử',
                                    'Thống kê',
                                    'Cài đặt',
                                  ];
                                  final icons = [
                                    Icons.grade,
                                    Icons.history,
                                    Icons.bar_chart,
                                    Icons.settings,
                                  ];
                                  return _featureTile(
                                    titles[index],
                                    icons[index],
                                    onTap: index == 0
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => BlocProvider(
                                                  create: (_) =>
                                                      sl<KanjiTableBloc>(),
                                                  child:
                                                      const KanjiTableListPage(),
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                  );
                                }),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fancyCard(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap,
    Gradient? gradient,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient:
              gradient ??
              LinearGradient(
                colors: [Colors.tealAccent.withOpacity(0.15), Colors.white10],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 32,
                color: iconColor ?? Colors.tealAccent.shade200,
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const Text(
                'Bắt đầu học ngay',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureTile(String title, IconData icon, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.tealAccent.shade200, size: 28),
              const Spacer(),
              Text(title, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
