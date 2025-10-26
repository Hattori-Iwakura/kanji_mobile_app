import 'package:flutter_test/flutter_test.dart';

import 'package:kanji_mobile_v1/features/kanji/data/models/kanji_model.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/entities/kanji.dart';

import '../../../helpers/fixtures/kanji_fixtures.dart';

void main() {
  group('KanjiModel', () {
    group('fromJson', () {
      test('should create valid model from JSON with all fields', () {
        // arrange
        final jsonMap = tKanjiJson;

        // act
        final result = KanjiModel.fromJson(jsonMap);

        // assert
        expect(result, isA<KanjiModel>());
        expect(result.id, tKanji1.id);
        expect(result.character, tKanji1.character);
        expect(result.onyomi, tKanji1.onyomi);
        expect(result.kunyomi, tKanji1.kunyomi);
        expect(result.meanings, tKanji1.meanings);
        expect(result.strokeCount, tKanji1.strokeCount);
        expect(result.jlpt, tKanji1.jlpt);
        expect(result.grade, tKanji1.grade);
        expect(result.frequency, tKanji1.frequency);
        expect(result.createdAt, tKanji1.createdAt);
        expect(result.updatedAt, tKanji1.updatedAt);
      });

      test('should create valid model from JSON with null optional fields', () {
        // arrange
        final jsonMap = {
          'id': 1,
          'character': '日',
          'meanings': 'sun, day',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        // act
        final result = KanjiModel.fromJson(jsonMap);

        // assert
        expect(result, isA<KanjiModel>());
        expect(result.id, 1);
        expect(result.character, '日');
        expect(result.onyomi, isNull);
        expect(result.kunyomi, isNull);
        expect(result.meanings, 'sun, day');
        expect(result.strokeCount, isNull);
        expect(result.jlpt, isNull);
        expect(result.grade, isNull);
        expect(result.frequency, isNull);
      });

      test('should throw error when required field id is missing', () {
        // arrange
        final jsonMap = {
          'character': '日',
          'meanings': 'sun, day',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        // act & assert
        expect(() => KanjiModel.fromJson(jsonMap), throwsA(isA<TypeError>()));
      });

      test('should throw error when required field character is missing', () {
        // arrange
        final jsonMap = {
          'id': 1,
          'meanings': 'sun, day',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        // act & assert
        expect(() => KanjiModel.fromJson(jsonMap), throwsA(isA<TypeError>()));
      });

      test('should throw error when createdAt is invalid format', () {
        // arrange
        final jsonMap = {
          'id': 1,
          'character': '日',
          'meanings': 'sun, day',
          'createdAt': 'invalid-date',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        // act & assert
        expect(
          () => KanjiModel.fromJson(jsonMap),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('toJson', () {
      test('should convert model to JSON map with all fields', () {
        // arrange
        final model = KanjiModel.fromEntity(tKanji1);

        // act
        final result = model.toJson();

        // assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], tKanji1.id);
        expect(result['character'], tKanji1.character);
        expect(result['onyomi'], tKanji1.onyomi);
        expect(result['kunyomi'], tKanji1.kunyomi);
        expect(result['meanings'], tKanji1.meanings);
        expect(result['strokeCount'], tKanji1.strokeCount);
        expect(result['jlpt'], tKanji1.jlpt);
        expect(result['grade'], tKanji1.grade);
        expect(result['frequency'], tKanji1.frequency);
        expect(result['createdAt'], tKanji1.createdAt.toIso8601String());
        expect(result['updatedAt'], tKanji1.updatedAt.toIso8601String());
      });

      test('should convert model to JSON with null optional fields', () {
        // arrange
        final model = KanjiModel.fromEntity(tKanjiMinimal);

        // act
        final result = model.toJson();

        // assert
        expect(result['id'], tKanjiMinimal.id);
        expect(result['character'], tKanjiMinimal.character);
        expect(result['onyomi'], isNull);
        expect(result['kunyomi'], isNull);
        expect(result['meanings'], tKanjiMinimal.meanings);
        expect(result['strokeCount'], isNull);
        expect(result['jlpt'], isNull);
        expect(result['grade'], isNull);
        expect(result['frequency'], isNull);
      });
    });

    group('toEntity', () {
      test('should convert model to Kanji entity', () {
        // arrange
        final model = KanjiModel.fromEntity(tKanji1);

        // act
        final result = model.toEntity();

        // assert
        expect(result, isA<Kanji>());
        expect(result.id, tKanji1.id);
        expect(result.character, tKanji1.character);
        expect(result.onyomi, tKanji1.onyomi);
        expect(result.kunyomi, tKanji1.kunyomi);
        expect(result.meanings, tKanji1.meanings);
        expect(result.strokeCount, tKanji1.strokeCount);
        expect(result.jlpt, tKanji1.jlpt);
        expect(result.grade, tKanji1.grade);
        expect(result.frequency, tKanji1.frequency);
      });
    });

    group('fromEntity', () {
      test('should create model from Kanji entity', () {
        // act
        final result = KanjiModel.fromEntity(tKanji1);

        // assert
        expect(result, isA<KanjiModel>());
        expect(result.id, tKanji1.id);
        expect(result.character, tKanji1.character);
        expect(result.onyomi, tKanji1.onyomi);
        expect(result.kunyomi, tKanji1.kunyomi);
        expect(result.meanings, tKanji1.meanings);
        expect(result.strokeCount, tKanji1.strokeCount);
        expect(result.jlpt, tKanji1.jlpt);
        expect(result.grade, tKanji1.grade);
        expect(result.frequency, tKanji1.frequency);
      });

      test('should preserve all data in entity-model-entity conversion', () {
        // act
        final model = KanjiModel.fromEntity(tKanji1);
        final entity = model.toEntity();

        // assert
        expect(entity.id, tKanji1.id);
        expect(entity.character, tKanji1.character);
        expect(entity.onyomi, tKanji1.onyomi);
        expect(entity.kunyomi, tKanji1.kunyomi);
        expect(entity.meanings, tKanji1.meanings);
        expect(entity.strokeCount, tKanji1.strokeCount);
        expect(entity.jlpt, tKanji1.jlpt);
        expect(entity.grade, tKanji1.grade);
        expect(entity.frequency, tKanji1.frequency);
        expect(entity.createdAt, tKanji1.createdAt);
        expect(entity.updatedAt, tKanji1.updatedAt);
      });
    });
  });
}
