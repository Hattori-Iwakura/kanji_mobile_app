import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_flutter/features/kanji_recognition/domain/entities/kanji_recognition_result.dart';
import 'package:kanji_flutter/features/kanji_recognition/data/models/kanji_recognition_result_model.dart';

void main() {
  group('KanjiRecognitionResult Entity Tests', () {
    final testTop5 = [
      Top5Prediction(character: '一', confidence: 0.95),
      Top5Prediction(character: '二', confidence: 0.03),
      Top5Prediction(character: '三', confidence: 0.01),
      Top5Prediction(character: '十', confidence: 0.005),
      Top5Prediction(character: '七', confidence: 0.003),
    ];

    final testResult = KanjiRecognitionResult(
      character: '一',
      confidence: 0.95,
      top5: testTop5,
    );

    test('should create KanjiRecognitionResult with correct properties', () {
      expect(testResult.character, '一');
      expect(testResult.confidence, 0.95);
      expect(testResult.top5.length, 5);
      expect(testResult.top5.first.character, '一');
      expect(testResult.top5.first.confidence, 0.95);
    });
  });

  group('Top5Prediction Entity Tests', () {
    test('should create Top5Prediction with correct properties', () {
      final prediction = Top5Prediction(character: '一', confidence: 0.95);

      expect(prediction.character, '一');
      expect(prediction.confidence, 0.95);
    });
  });

  group('KanjiRecognitionResultModel Tests', () {
    final testJson = {
      'character': '一',
      'confidence': 0.95,
      'top5': [
        {'character': '一', 'confidence': 0.95},
        {'character': '二', 'confidence': 0.03},
        {'character': '三', 'confidence': 0.01},
        {'character': '十', 'confidence': 0.005},
        {'character': '七', 'confidence': 0.003},
      ],
    };

    final testModel = KanjiRecognitionResultModel(
      character: '一',
      confidence: 0.95,
      top5: [
        Top5PredictionModel(character: '一', confidence: 0.95),
        Top5PredictionModel(character: '二', confidence: 0.03),
        Top5PredictionModel(character: '三', confidence: 0.01),
        Top5PredictionModel(character: '十', confidence: 0.005),
        Top5PredictionModel(character: '七', confidence: 0.003),
      ],
    );

    group('fromJson', () {
      test('should create KanjiRecognitionResultModel from valid JSON', () {
        final model = KanjiRecognitionResultModel.fromJson(testJson);

        expect(model.character, '一');
        expect(model.confidence, 0.95);
        expect(model.top5.length, 5);
        expect(model.top5.first.character, '一');
        expect(model.top5.first.confidence, 0.95);
      });

      test('should handle empty top5 list', () {
        final jsonWithEmptyTop5 = {
          'character': '一',
          'confidence': 0.95,
          'top5': [],
        };

        final model = KanjiRecognitionResultModel.fromJson(jsonWithEmptyTop5);

        expect(model.top5, isEmpty);
      });

      test('should handle null top5 list', () {
        final jsonWithNullTop5 = {
          'character': '一',
          'confidence': 0.95,
          'top5': null,
        };

        final model = KanjiRecognitionResultModel.fromJson(jsonWithNullTop5);

        expect(model.top5, isEmpty);
      });

      test('should handle missing character with empty string', () {
        final jsonWithoutChar = {'confidence': 0.95, 'top5': []};

        final model = KanjiRecognitionResultModel.fromJson(jsonWithoutChar);

        expect(model.character, '');
      });

      test('should handle missing confidence with 0.0', () {
        final jsonWithoutConf = {'character': '一', 'top5': []};

        final model = KanjiRecognitionResultModel.fromJson(jsonWithoutConf);

        expect(model.confidence, 0.0);
      });
    });

    group('toJson', () {
      test('should convert KanjiRecognitionResultModel to valid JSON', () {
        final json = testModel.toJson();

        expect(json['character'], '一');
        expect(json['confidence'], 0.95);
        expect(json['top5'], isA<List>());
        expect(json['top5'].length, 5);
        expect(json['top5'][0]['character'], '一');
        expect(json['top5'][0]['confidence'], 0.95);
      });
    });

    group('JSON roundtrip', () {
      test('should maintain data integrity through JSON conversion', () {
        final json = testModel.toJson();
        final fromJson = KanjiRecognitionResultModel.fromJson(json);

        expect(fromJson.character, testModel.character);
        expect(fromJson.confidence, testModel.confidence);
        expect(fromJson.top5.length, testModel.top5.length);
        expect(fromJson.top5.first.character, testModel.top5.first.character);
        expect(fromJson.top5.first.confidence, testModel.top5.first.confidence);
      });
    });
  });

  group('Top5PredictionModel Tests', () {
    final testJson = {'character': '一', 'confidence': 0.95};

    final testModel = Top5PredictionModel(character: '一', confidence: 0.95);

    group('fromJson', () {
      test('should create Top5PredictionModel from valid JSON', () {
        final model = Top5PredictionModel.fromJson(testJson);

        expect(model.character, '一');
        expect(model.confidence, 0.95);
      });

      test('should handle missing character', () {
        final jsonWithoutChar = {'confidence': 0.95};
        final model = Top5PredictionModel.fromJson(jsonWithoutChar);

        expect(model.character, '');
      });

      test('should handle missing confidence', () {
        final jsonWithoutConf = {'character': '一'};
        final model = Top5PredictionModel.fromJson(jsonWithoutConf);

        expect(model.confidence, 0.0);
      });
    });

    group('toJson', () {
      test('should convert Top5PredictionModel to valid JSON', () {
        final json = testModel.toJson();

        expect(json['character'], '一');
        expect(json['confidence'], 0.95);
      });
    });

    group('JSON roundtrip', () {
      test('should maintain data integrity through JSON conversion', () {
        final json = testModel.toJson();
        final fromJson = Top5PredictionModel.fromJson(json);

        expect(fromJson.character, testModel.character);
        expect(fromJson.confidence, testModel.confidence);
      });
    });
  });
}
