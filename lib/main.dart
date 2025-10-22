import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/constants/api_endpoints.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize API endpoints with env variables
  // Use localhost for web, 10.0.2.2 for Android emulator
  final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  final aiUrl = dotenv.env['AI_MODEL_URL'] ?? 'http://localhost:8000';

  ApiEndpoints.init(baseUrl, aiUrl);

  // Setup dependency injection
  await setupDependencyInjection();

  // Initialize AuthBloc ONCE globally
  final authBloc = getIt<AuthBloc>()..add(CheckAuthStatusEvent());

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider.value(value: authBloc)],
      child: const KanjiMasterApp(),
    ),
  );
}
