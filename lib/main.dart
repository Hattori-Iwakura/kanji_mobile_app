import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/constants/api_endpoints.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize API endpoints with env variables
  ApiEndpoints.init(
    dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000',
    dotenv.env['AI_MODEL_URL'] ?? 'http://10.0.2.2:8000',
  );

  // Setup dependency injection
  await setupDependencyInjection();

  runApp(const KanjiMasterApp());
}
