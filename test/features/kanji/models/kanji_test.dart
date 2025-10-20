import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_flutter/features/kanji/models/kanji.dart';

void main() {
  group('Kanji Model Tests', () {
    final testJson = {
      'id': 1,
      'character': '一',
      'jlptLevel': 'N5',
      'grade': 1,
      'strokeCount': 1,
      'meanings': ['one', 'first'],
      'frequency': 2,
      'onyomi': 'イチ、イツ',
      'kunyomi': 'ひと、ひと.つ',
      'hanviet': 'nhất',
      'meaningMnemonic': 'Single horizontal stroke',
      'readingMnemonic': 'Read as ichi',
      'createdAt': '2025-01-01T00:00:00.000Z',
      'updatedAt': '2025-01-01T00:00:00.000Z',
    };

    final testKanji = Kanji(
      id: 1,
      character: '一',
      jlptLevel: 'N5',
      grade: 1,
      strokeCount: 1,
      meanings: const ['one', 'first'],
      frequency: 2,
      onyomi: 'イチ、イツ',
      kunyomi: 'ひと、ひと.つ',
      hanviet: 'nhất',
      meaningMnemonic: 'Single horizontal stroke',
      readingMnemonic: 'Read as ichi',
      createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
    );

    group('fromJson', () {
      test('should create Kanji from valid JSON', () {
        final kanji = Kanji.fromJson(testJson);

        expect(kanji.id, 1);
        expect(kanji.character, '一');
        expect(kanji.jlptLevel, 'N5');
        expect(kanji.grade, 1);
        expect(kanji.strokeCount, 1);
        expect(kanji.meanings, ['one', 'first']);
        expect(kanji.frequency, 2);
        expect(kanji.onyomi, 'イチ、イツ');
        expect(kanji.kunyomi, 'ひと、ひと.つ');
        expect(kanji.hanviet, 'nhất');
        expect(kanji.meaningMnemonic, 'Single horizontal stroke');
        expect(kanji.readingMnemonic, 'Read as ichi');
      });

      test('should handle null optional fields', () {
        final jsonWithNulls = {
          'id': 1,
          'character': '一',
          'jlptLevel': null,
          'grade': null,
          'strokeCount': 1,
          'meanings': ['one'],
          'frequency': null,
          'onyomi': null,
          'kunyomi': null,
          'hanviet': null,
          'meaningMnemonic': null,
          'readingMnemonic': null,
          'createdAt': '2025-01-01T00:00:00.000Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
        };

        final kanji = Kanji.fromJson(jsonWithNulls);

        expect(kanji.jlptLevel, isNull);
        expect(kanji.grade, isNull);
        expect(kanji.frequency, isNull);
        expect(kanji.onyomi, isNull);
        expect(kanji.kunyomi, isNull);
        expect(kanji.hanviet, isNull);
        expect(kanji.meaningMnemonic, isNull);
        expect(kanji.readingMnemonic, isNull);
      });

      test('should parse empty meanings list', () {
        final jsonWithEmptyMeanings = {...testJson, 'meanings': []};

        final kanji = Kanji.fromJson(jsonWithEmptyMeanings);

        expect(kanji.meanings, isEmpty);
      });
    });

    group('toJson', () {
      test('should convert Kanji to JSON', () {
        final json = testKanji.toJson();

        expect(json['id'], 1);
        expect(json['character'], '一');
        expect(json['jlptLevel'], 'N5');
        expect(json['grade'], 1);
        expect(json['strokeCount'], 1);
        expect(json['meanings'], ['one', 'first']);
        expect(json['frequency'], 2);
        expect(json['onyomi'], 'イチ、イツ');
        expect(json['kunyomi'], 'ひと、ひと.つ');
        expect(json['hanviet'], 'nhất');
        expect(json['meaningMnemonic'], 'Single horizontal stroke');
        expect(json['readingMnemonic'], 'Read as ichi');
      });

      test('should include null values in JSON', () {
        final kanjiWithNulls = Kanji(
          id: 1,
          character: '一',
          strokeCount: 1,
          meanings: const ['one'],
          createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
        );

        final json = kanjiWithNulls.toJson();

        expect(json['jlptLevel'], isNull);
        expect(json['grade'], isNull);
        expect(json['frequency'], isNull);
        expect(json['onyomi'], isNull);
        expect(json['kunyomi'], isNull);
        expect(json['hanviet'], isNull);
        expect(json['meaningMnemonic'], isNull);
        expect(json['readingMnemonic'], isNull);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are the same', () {
        final kanji1 = Kanji.fromJson(testJson);
        final kanji2 = Kanji.fromJson(testJson);

        expect(kanji1, equals(kanji2));
      });

      test('should not be equal when properties differ', () {
        final kanji1 = Kanji.fromJson(testJson);
        final kanji2 = Kanji.fromJson({...testJson, 'character': '二'});

        expect(kanji1, isNot(equals(kanji2)));
      });

      test('should have same hashCode when equal', () {
        final kanji1 = Kanji.fromJson(testJson);
        final kanji2 = Kanji.fromJson(testJson);

        expect(kanji1.hashCode, equals(kanji2.hashCode));
      });
    });

    group('Edge Cases', () {
      test('should handle very long meanings list', () {
        final jsonWithManyMeanings = {
          ...testJson,
          'meanings': List.generate(50, (i) => 'meaning$i'),
        };

        final kanji = Kanji.fromJson(jsonWithManyMeanings);

        expect(kanji.meanings.length, 50);
        expect(kanji.meanings.first, 'meaning0');
        expect(kanji.meanings.last, 'meaning49');
      });

      test('should handle special characters in readings', () {
        final jsonWithSpecialChars = {
          ...testJson,
          'onyomi': 'カイ、ケ',
          'kunyomi': 'あ.ける、あ.く',
        };

        final kanji = Kanji.fromJson(jsonWithSpecialChars);

        expect(kanji.onyomi, 'カイ、ケ');
        expect(kanji.kunyomi, 'あ.ける、あ.く');
      });
    });
  });
}
