import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile/features/kanji/domain/entities/kanji.dart';

void main() {
  group('Kanji Entity', () {
    test('should create a Kanji instance with all properties', () {
      // arrange
      const kanji = Kanji(
        id: 1,
        character: '一',
        strokes: 1,
        grade: 1,
        freq: 2,
        jlptOld: 4,
        jlptNew: 5,
        meanings: ['One'],
        readingsOn: ['いち', 'いつ'],
        readingsKun: ['ひと'],
        wkLevel: 1,
      );

      // assert
      expect(kanji.id, 1);
      expect(kanji.character, '一');
      expect(kanji.strokes, 1);
      expect(kanji.grade, 1);
      expect(kanji.meanings, ['One']);
    });

    test('should support equality comparison', () {
      // arrange
      const kanji1 = Kanji(
        id: 1,
        character: '一',
        strokes: 1,
        meanings: ['One'],
        readingsOn: ['いち'],
        readingsKun: ['ひと'],
      );

      const kanji2 = Kanji(
        id: 1,
        character: '一',
        strokes: 1,
        meanings: ['One'],
        readingsOn: ['いち'],
        readingsKun: ['ひと'],
      );

      // assert
      expect(kanji1, equals(kanji2));
    });

    test('should not be equal if properties differ', () {
      // arrange
      const kanji1 = Kanji(
        id: 1,
        character: '一',
        strokes: 1,
        meanings: ['One'],
        readingsOn: ['いち'],
        readingsKun: ['ひと'],
      );

      const kanji2 = Kanji(
        id: 2,
        character: '二',
        strokes: 2,
        meanings: ['Two'],
        readingsOn: ['に'],
        readingsKun: ['ふた'],
      );

      // assert
      expect(kanji1, isNot(equals(kanji2)));
    });
  });
}
