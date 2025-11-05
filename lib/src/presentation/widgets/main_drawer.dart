import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../../../features/quiz/presentation/pages/quiz_list_page.dart';
import '../../../features/kanji_table/presentation/pages/kanji_table_list_page.dart';
import '../../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../../features/settings/presentation/pages/settings_page.dart';
import '../../../injection_container.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071126), Color(0xFF0B0F14)],
          ),
        ),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final isAuthenticated = authState is Authenticated;
            final user = isAuthenticated ? authState.user : null;
            final isAdmin = user?.role == 'ADMIN';

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerHeader(context, isAuthenticated, user),

                // Learning Section
                _buildSectionHeader('Học tập'),
                _buildTile(
                  context,
                  Icons.quiz_rounded,
                  'Quiz',
                  subtitle: 'Luyện tập kiến thức',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizListPage()),
                    );
                  },
                ),
                _buildTile(
                  context,
                  Icons.style_rounded,
                  'Flashcards',
                  subtitle: 'Ôn tập với thẻ ghi nhớ',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFA8BFF), Color(0xFF2BD2FF)],
                  ),
                  onTap: () => Navigator.pop(context),
                ),

                const Divider(color: Colors.white10, height: 24),

                // Content Section
                _buildSectionHeader('Nội dung'),
                _buildTile(
                  context,
                  Icons.translate_rounded,
                  'Danh sách Kanji',
                  subtitle: 'Tra cứu và học Kanji',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                if (isAuthenticated)
                  _buildTile(
                    context,
                    Icons.table_chart_rounded,
                    'Bảng Kanji của tôi',
                    subtitle: 'Quản lý bảng tùy chỉnh',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KanjiTableListPage(),
                        ),
                      );
                    },
                  ),

                const Divider(color: Colors.white10, height: 24),

                // Account Section
                _buildSectionHeader('Tài khoản'),
                if (isAuthenticated) ...[
                  _buildTile(
                    context,
                    Icons.person_rounded,
                    'Hồ sơ cá nhân',
                    subtitle: 'Thông tin và thống kê',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfilePage(apiClient: sl<ApiClient>()),
                        ),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    Icons.settings_rounded,
                    'Cài đặt',
                    subtitle: 'Tùy chỉnh ứng dụng',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF868F96), Color(0xFF596164)],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                ],

                if (isAdmin) ...[
                  const Divider(color: Colors.white10, height: 24),
                  _buildSectionHeader('Quản trị'),
                  _buildTile(
                    context,
                    Icons.admin_panel_settings_rounded,
                    'Admin Dashboard',
                    subtitle: 'Quản lý hệ thống',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminDashboardPage(apiClient: sl<ApiClient>()),
                        ),
                      );
                    },
                  ),
                ],

                const Divider(color: Colors.white10, height: 24),

                // Auth Section
                const SizedBox(height: 8),
                if (isAuthenticated)
                  _buildLogoutButton(context)
                else
                  _buildLoginButton(context),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    bool isAuthenticated,
    dynamic user,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.tealAccent.withOpacity(0.15), Colors.transparent],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.tealAccent.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kanji App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Learn Japanese Kanji',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isAuthenticated) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.tealAccent.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.tealAccent.withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      color: Colors.tealAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.tealAccent.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title, {
    String? subtitle,
    Gradient? gradient,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient:
                gradient ??
                const LinearGradient(
                  colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
                ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1A1F2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Xác nhận đăng xuất',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Bạn có chắc chắn muốn đăng xuất?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.read<AuthBloc>().add(LogoutEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Đăng xuất'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withOpacity(0.2),
          foregroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.redAccent, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        },
        icon: const Icon(Icons.login_rounded),
        label: const Text('Đăng nhập'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent.withOpacity(0.2),
          foregroundColor: Colors.tealAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.tealAccent, width: 1),
          ),
        ),
      ),
    );
  }
}
