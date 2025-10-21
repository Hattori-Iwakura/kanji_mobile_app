import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'injection_container.dart' as di;
import 'core/theme/app_themes.dart';
import 'core/theme/theme_provider.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'core/config/env_config.dart';

// Auth
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

// Admin - Category
import 'features/admin/presentation/bloc/category_bloc.dart';

// Home
import 'features/home/presentation/pages/user_landing_page.dart';

// Admin
import 'features/admin/presentation/pages/admin_dashboard_page.dart';

// Kanji Recognition (preserved)
import 'features/kanji_recognition/presentation/bloc/kanji_recognition_bloc.dart';
import 'features/kanji_recognition/presentation/pages/kanji_drawing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Print config in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('Environment loaded successfully');
      EnvConfig.printConfig();
    }

    await di.init();

    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('❌ FATAL ERROR during app initialization:');
    print('Error: $e');
    print('Stack trace: $stackTrace');

    // Show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'App Initialization Failed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(create: (context) => di.sl<CategoryBloc>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Kanji Learning App',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            onGenerateRoute: RouteGenerator.generateRoute,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading || state is AuthInitial) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is Authenticated) {
                  // Role-based routing: Admin → AdminDashboard, User → UserLandingPage
                  // NOTE: Backend returns 'ADMIN' (uppercase), not 'admin'
                  if (state.user.role.toUpperCase() == 'ADMIN') {
                    return const AdminDashboardPage();
                  } else {
                    return const UserLandingPage();
                  }
                } else {
                  // Navigate to login using named route
                  Future.microtask(
                    () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    ),
                  );
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
            routes: {
              '/kanji-recognition': (ctx) => BlocProvider(
                create: (context) => di.sl<KanjiRecognitionBloc>(),
                child: const KanjiDrawingPage(),
              ),
            },
          );
        },
      ),
    );
  }
}
