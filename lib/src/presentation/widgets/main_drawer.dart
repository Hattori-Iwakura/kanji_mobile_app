import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../../../injection_container.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF07121A),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final isAuthenticated = authState is Authenticated;
            final user = isAuthenticated ? authState.user : null;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.tealAccent.withOpacity(0.14),
                        Colors.white10,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: InkWell(
                    onTap: isAuthenticated
                        ? () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfilePage(apiClient: sl<ApiClient>()),
                              ),
                            );
                          }
                        : null,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white12,
                          child: Icon(
                            Icons.person,
                            size: 34,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAuthenticated ? user!.name : 'Khách',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isAuthenticated
                                    ? user!.email
                                    : 'Chưa đăng nhập',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              if (isAuthenticated) ...[
                                const SizedBox(height: 4),
                                const Text(
                                  'Xem hồ sơ →',
                                  style: TextStyle(
                                    color: Color(0xFF00BFA5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildTile(context, Icons.school, 'Học', onTap: () {}),
                _buildTile(context, Icons.flash_on, 'Flashcards', onTap: () {}),
                _buildTile(context, Icons.quiz, 'Quiz', onTap: () {}),
                const Divider(color: Colors.white10),
                _buildTile(
                  context,
                  Icons.list,
                  'Danh sách Kanji',
                  onTap: () {},
                ),
                _buildTile(context, Icons.history, 'Lịch sử học', onTap: () {}),
                _buildTile(context, Icons.bar_chart, 'Thống kê', onTap: () {}),
                const Divider(color: Colors.white10),
                if (isAuthenticated)
                  _buildTile(
                    context,
                    Icons.account_circle,
                    'Hồ sơ cá nhân',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfilePage(apiClient: sl<ApiClient>()),
                        ),
                      );
                    },
                  ),
                _buildTile(context, Icons.settings, 'Cài đặt', onTap: () {}),
                _buildTile(context, Icons.info, 'Giới thiệu', onTap: () {}),
                const SizedBox(height: 12),
                if (isAuthenticated)
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      context.read<AuthBloc>().add(LogoutEvent());
                      Navigator.of(context).pop();
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.tealAccent),
                    title: const Text(
                      'Đăng nhập',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.tealAccent.shade200),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
