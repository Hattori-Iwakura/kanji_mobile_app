# Environment Configuration

## Overview

This project uses `flutter_dotenv` to manage environment variables. Configuration is loaded from `.env` file at app startup.

## Setup

### 1. Environment File

The `.env` file is located at the root of the project:

```env
# API Configuration
API_BASE_URL=http://localhost:3000
API_TIMEOUT=30000

# AI Model Configuration
AI_MODEL_URL=http://localhost:8000

# Feature Flags
ENABLE_DEBUG_MODE=true
ENABLE_ANALYTICS=false

# App Configuration
APP_NAME=Kanji Learning App
APP_VERSION=1.0.0
```

### 2. Usage in Code

#### Import EnvConfig

```dart
import 'package:kanji_flutter/core/config/env_config.dart';
```

#### Access Configuration Values

```dart
// API Configuration
String apiUrl = EnvConfig.apiBaseUrl;      // "http://localhost:3000"
int timeout = EnvConfig.apiTimeout;         // 30000

// AI Model Configuration
String aiUrl = EnvConfig.aiModelUrl;        // "http://localhost:8000"

// Feature Flags
bool isDebug = EnvConfig.isDebugMode;       // true
bool analytics = EnvConfig.isAnalyticsEnabled; // false

// App Info
String appName = EnvConfig.appName;         // "Kanji Learning App"
String version = EnvConfig.appVersion;      // "1.0.0"
```

#### Get Raw Environment Variable

```dart
String? customValue = EnvConfig.getEnv('CUSTOM_KEY');
```

#### Print All Configuration (Debug Only)

```dart
EnvConfig.printConfig();
```

## Integration Examples

### 1. API Client (Already Integrated)

The `ApiClient` automatically uses environment configuration:

```dart
// lib/core/network/api_client.dart
final timeoutDuration = Duration(milliseconds: EnvConfig.apiTimeout);

dio = Dio(
  BaseOptions(
    baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
    connectTimeout: timeoutDuration,
    receiveTimeout: timeoutDuration,
    // ...
  ),
);
```

### 2. API Endpoints (Already Integrated)

Endpoints dynamically use environment URLs:

```dart
// lib/core/network/endpoint.dart
class ApiEndpoints {
  static String get baseUrl => "${EnvConfig.apiBaseUrl}/api";
  static String get kanjiRecognition => "${EnvConfig.aiModelUrl}/api/v1/recognize";
}
```

### 3. Routes (Already Integrated)

Routes can access environment config for debugging:

```dart
// lib/core/routes/route_generator.dart
if (EnvConfig.isDebugMode) {
  print('Navigating to: ${settings.name}');
  print('API Base URL: ${EnvConfig.apiBaseUrl}');
}
```

### 4. Custom Feature Implementation

You can use EnvConfig anywhere in your app:

```dart
// Example: Conditional feature based on environment
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (EnvConfig.isDebugMode) {
      return DebugBanner(
        child: MyContent(),
      );
    }
    return MyContent();
  }
}
```

## Different Environments

### Development
```env
API_BASE_URL=http://localhost:3000
ENABLE_DEBUG_MODE=true
```

### Staging
```env
API_BASE_URL=https://staging-api.example.com
ENABLE_DEBUG_MODE=false
ENABLE_ANALYTICS=true
```

### Production
```env
API_BASE_URL=https://api.example.com
ENABLE_DEBUG_MODE=false
ENABLE_ANALYTICS=true
```

You can create multiple `.env` files:
- `.env` - Default
- `.env.dev` - Development
- `.env.staging` - Staging
- `.env.prod` - Production

And load them conditionally:

```dart
await dotenv.load(fileName: ".env.prod");
```

## Important Notes

1. **Never commit sensitive data**: Add `.env` to `.gitignore`
2. **Provide example file**: Create `.env.example` with dummy values
3. **Type Safety**: All values from `.env` are strings, use proper parsing
4. **Default Values**: EnvConfig provides sensible defaults if keys are missing
5. **Loading Order**: Environment must be loaded before using any config values

## Troubleshooting

### Issue: "Unable to load asset: .env"

**Solution**: Make sure `.env` is listed in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

### Issue: Environment values are null

**Solution**: Check that:
1. `.env` file exists in project root
2. Keys in `.env` match those in `EnvConfig`
3. `dotenv.load()` is called before accessing values

### Issue: Changes to .env not reflecting

**Solution**: 
1. Stop the app completely
2. Run `flutter clean`
3. Run `flutter pub get`
4. Restart the app
