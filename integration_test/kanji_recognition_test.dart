import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Kanji Recognition Integration Tests', () {
    late IntegrationTestHelper helper;

    setUpAll(() async {
      helper = IntegrationTestHelper();

      // Check if backend server is running
      final isRunning = await helper.isBackendRunning();
      if (!isRunning) {
        throw Exception(
          'Backend server is not running! '
          'Please start it with: cd kanji-web-be && npm run start:dev',
        );
      }

      // Register test user (if not exists)
      await helper.registerTestUser();

      // Login to get auth token
      await helper.loginAndGetToken();
    });

    tearDownAll(() async {
      await helper.cleanup();
    });

    test('Server health check', () async {
      final isRunning = await helper.isBackendRunning();
      expect(isRunning, true, reason: 'Backend server should be running');
    });

    test('Recognize kanji - Success with valid image', () async {
      // Create a simple test image (white 28x28 square - simulating drawn kanji)
      // In real scenario, this would be an actual kanji drawing
      final testImage = _createTestKanjiImage();
      final base64Image = base64Encode(testImage);

      try {
        final response = await helper.apiClient.post(
          '/kanji-recognition/recognize',
          {'image': base64Image},
        );

        expect(response.statusCode, 200);
        expect(response.data, isNotNull);
        expect(response.data['character'], isNotNull);
        expect(response.data['confidence'], isNotNull);
        expect(response.data['confidence'], isA<double>());
        expect(response.data['confidence'], greaterThanOrEqualTo(0.0));
        expect(response.data['confidence'], lessThanOrEqualTo(1.0));

        // Check top5 predictions
        expect(response.data['top5'], isNotNull);
        expect(response.data['top5'], isA<List>());
        expect(response.data['top5'].length, greaterThan(0));
        expect(response.data['top5'].length, lessThanOrEqualTo(5));

        // Validate top5 structure
        for (final prediction in response.data['top5']) {
          expect(prediction['character'], isNotNull);
          expect(prediction['confidence'], isNotNull);
          expect(prediction['confidence'], isA<double>());
        }

        print('✅ Recognition successful!');
        print('   Character: ${response.data['character']}');
        print('   Confidence: ${response.data['confidence']}');
        print('   Top 5: ${response.data['top5']}');
      } catch (e) {
        if (e.toString().contains('500') ||
            e.toString().contains('ECONNREFUSED')) {
          throw Exception(
            'ML Server (FastAPI) is not running or not accessible!\n'
            'Please start it with: cd cnn-kanji && uvicorn src.main:app --reload\n'
            'Original error: $e',
          );
        }
        rethrow;
      }
    });

    test('Recognize kanji - Fail with invalid image format', () async {
      try {
        await helper.apiClient.post('/kanji-recognition/recognize', {
          'image': 'invalid-base64-string',
        });
        fail('Should throw exception for invalid image');
      } catch (e) {
        expect(e.toString(), contains('400'));
        print('✅ Correctly rejected invalid image format');
      }
    });

    test('Recognize kanji - Fail without authentication', () async {
      // Save current token
      final currentToken = helper.authToken;

      // Clear auth token temporarily
      helper.apiClient.clearAuthToken();
      helper.authToken = null;

      try {
        final testImage = _createTestKanjiImage();
        final base64Image = base64Encode(testImage);

        await helper.apiClient.post('/kanji-recognition/recognize', {
          'image': base64Image,
        });
        fail('Should throw exception without auth token');
      } catch (e) {
        expect(e.toString(), contains('401'));
        print('✅ Correctly rejected unauthenticated request');
      } finally {
        // Restore token
        if (currentToken != null) {
          helper.authToken = currentToken;
          helper.apiClient.setAuthToken(currentToken);
        }
      }
    });

    test('Recognize kanji - Fail with empty image', () async {
      try {
        await helper.apiClient.post('/kanji-recognition/recognize', {
          'image': '',
        });
        fail('Should throw exception for empty image');
      } catch (e) {
        expect(e.toString(), contains('400'));
        print('✅ Correctly rejected empty image');
      }
    });

    test('Recognize kanji - Multiple predictions in top5', () async {
      final testImage = _createTestKanjiImage();
      final base64Image = base64Encode(testImage);

      final response = await helper.apiClient.post(
        '/kanji-recognition/recognize',
        {'image': base64Image},
      );

      final top5 = response.data['top5'] as List;

      // Verify predictions are sorted by confidence (descending)
      for (int i = 0; i < top5.length - 1; i++) {
        final current = top5[i]['confidence'] as double;
        final next = top5[i + 1]['confidence'] as double;
        expect(
          current,
          greaterThanOrEqualTo(next),
          reason: 'Predictions should be sorted by confidence',
        );
      }

      // Verify top prediction matches the main result
      expect(
        response.data['character'],
        equals(top5[0]['character']),
        reason: 'Top character should match first prediction',
      );

      expect(
        response.data['confidence'],
        equals(top5[0]['confidence']),
        reason: 'Top confidence should match first prediction',
      );

      print('✅ Top5 predictions validated successfully');
    });
  });
}

/// Create a simple test image (simulating a drawn kanji)
/// Returns PNG bytes
Uint8List _createTestKanjiImage() {
  // Create a simple 28x28 white square on black background
  // This is a minimal PNG image
  // In real test, you would use actual kanji drawing or load test images

  // Simple 1x1 white pixel PNG (minimal valid image)
  final pngBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==',
  );

  return pngBytes;
}
