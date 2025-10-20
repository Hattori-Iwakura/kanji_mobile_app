import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/navigation_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Learning'),
        centerTitle: true,
        elevation: 2,
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isAdmin =
                  state is Authenticated && state.user.role == 'admin';

              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  NavigationCard(
                    icon: Icons.book,
                    title: 'Dictionary',
                    subtitle: 'Browse kanji characters',
                    color: Colors.blue,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.kanjiDictionary),
                  ),
                  NavigationCard(
                    icon: Icons.list,
                    title: 'My Lists',
                    subtitle: 'Custom kanji collections',
                    color: Colors.green,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.kanjiLists),
                  ),
                  NavigationCard(
                    icon: Icons.search,
                    title: 'Search',
                    subtitle: 'Find kanji by drawing',
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                  ),
                  NavigationCard(
                    icon: Icons.style,
                    title: 'Flashcards',
                    subtitle: 'Study with flashcards',
                    color: Colors.purple,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.flashcardDecks),
                  ),
                  NavigationCard(
                    icon: Icons.quiz,
                    title: 'Quizzes',
                    subtitle: 'Test your knowledge',
                    color: Colors.red,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.quizList),
                  ),
                  NavigationCard(
                    icon: Icons.person,
                    title: 'Profile',
                    subtitle: 'View your progress',
                    color: Colors.teal,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                  if (isAdmin)
                    NavigationCard(
                      icon: Icons.admin_panel_settings,
                      title: 'Admin Panel',
                      subtitle: 'Manage platform',
                      color: Colors.deepPurple,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.adminDashboard,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
