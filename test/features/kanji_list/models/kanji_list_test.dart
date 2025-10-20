import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_flutter/features/kanji_list/models/kanji_list.dart';

void main() {
  group('KanjiList Model Tests', () {
    final testJson = {
      'id': 1,
      'name': 'JLPT N5 Kanji',
      'description': 'Essential kanji for N5 level',
      'type': 'SYSTEM',
      'level': 'N5',
      'kanjiCount': 80,
      'userId': null,
      'createdAt': '2025-01-01T00:00:00.000Z',
      'updatedAt': '2025-01-01T00:00:00.000Z',
    };

    final testKanjiList = KanjiList(
      id: 1,
      name: 'JLPT N5 Kanji',
      description: 'Essential kanji for N5 level',
      type: 'SYSTEM',
      level: 'N5',
      kanjiCount: 80,
      userId: null,
      createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
    );

    group('fromJson', () {
      test('should create KanjiList from valid JSON', () {
        final kanjiList = KanjiList.fromJson(testJson);

        expect(kanjiList.id, 1);
        expect(kanjiList.name, 'JLPT N5 Kanji');
        expect(kanjiList.description, 'Essential kanji for N5 level');
        expect(kanjiList.type, 'SYSTEM');
        expect(kanjiList.level, 'N5');
        expect(kanjiList.kanjiCount, 80);
        expect(kanjiList.userId, null);
        expect(kanjiList.createdAt, DateTime.parse('2025-01-01T00:00:00.000Z'));
        expect(kanjiList.updatedAt, DateTime.parse('2025-01-01T00:00:00.000Z'));
      });

      test('should handle custom list JSON', () {
        final customJson = {
          'id': 2,
          'name': 'My Custom List',
          'description': 'Personal study list',
          'type': 'CUSTOM',
          'level': null,
          'kanjiCount': 25,
          'userId': 123,
          'createdAt': '2025-01-15T00:00:00.000Z',
          'updatedAt': '2025-01-15T00:00:00.000Z',
        };

        final kanjiList = KanjiList.fromJson(customJson);

        expect(kanjiList.id, 2);
        expect(kanjiList.name, 'My Custom List');
        expect(kanjiList.type, 'CUSTOM');
        expect(kanjiList.level, null);
        expect(kanjiList.userId, 123);
      });

      test('should handle null description', () {
        final jsonWithNullDesc = {
          'id': 1,
          'name': 'Test List',
          'description': null,
          'type': 'CUSTOM',
          'level': null,
          'kanjiCount': 0,
          'userId': 1,
          'createdAt': '2025-01-01T00:00:00.000Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
        };

        final kanjiList = KanjiList.fromJson(jsonWithNullDesc);

        expect(kanjiList.description, null);
      });
    });

    group('toJson', () {
      test('should convert KanjiList to valid JSON', () {
        final json = testKanjiList.toJson();

        expect(json['id'], 1);
        expect(json['name'], 'JLPT N5 Kanji');
        expect(json['description'], 'Essential kanji for N5 level');
        expect(json['type'], 'SYSTEM');
        expect(json['level'], 'N5');
        expect(json['kanjiCount'], 80);
        expect(json['userId'], null);
        expect(json['createdAt'], '2025-01-01T00:00:00.000Z');
        expect(json['updatedAt'], '2025-01-01T00:00:00.000Z');
      });

      test('should handle custom list toJson', () {
        final customList = KanjiList(
          id: 2,
          name: 'My List',
          description: null,
          type: 'CUSTOM',
          level: null,
          kanjiCount: 10,
          userId: 5,
          createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
        );

        final json = customList.toJson();

        expect(json['type'], 'CUSTOM');
        expect(json['description'], null);
        expect(json['level'], null);
        expect(json['userId'], 5);
      });
    });

    group('Equatable', () {
      test('should be equal when properties are the same', () {
        final list1 = testKanjiList;
        final list2 = KanjiList(
          id: 1,
          name: 'JLPT N5 Kanji',
          description: 'Essential kanji for N5 level',
          type: 'SYSTEM',
          level: 'N5',
          kanjiCount: 80,
          userId: null,
          createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
        );

        expect(list1, equals(list2));
      });

      test('should not be equal when properties differ', () {
        final list1 = testKanjiList;
        final list2 = KanjiList(
          id: 2,
          name: 'Different List',
          description: 'Different description',
          type: 'CUSTOM',
          level: null,
          kanjiCount: 50,
          userId: 1,
          createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
        );

        expect(list1, isNot(equals(list2)));
      });

      test('should have same hashCode when equal', () {
        final list1 = testKanjiList;
        final list2 = KanjiList(
          id: 1,
          name: 'JLPT N5 Kanji',
          description: 'Essential kanji for N5 level',
          type: 'SYSTEM',
          level: 'N5',
          kanjiCount: 80,
          userId: null,
          createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
        );

        expect(list1.hashCode, equals(list2.hashCode));
      });
    });

    group('JSON roundtrip', () {
      test('should maintain data integrity through JSON conversion', () {
        final original = testKanjiList;
        final json = original.toJson();
        final fromJson = KanjiList.fromJson(json);

        expect(fromJson, equals(original));
        expect(fromJson.id, original.id);
        expect(fromJson.name, original.name);
        expect(fromJson.description, original.description);
        expect(fromJson.type, original.type);
        expect(fromJson.level, original.level);
        expect(fromJson.kanjiCount, original.kanjiCount);
      });
    });
  });
}
