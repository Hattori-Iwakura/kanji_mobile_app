import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/kanji_list/data/models/kanji_list_model.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/entities/kanji_list.dart';

import '../../../helpers/fixtures/kanji_list_fixtures.dart';

void main() {
  group('KanjiListModel', () {
    test('should be a subclass of KanjiList entity', () {
      // arrange
      final model = KanjiListModel.fromJson(tKanjiListJson);

      // act & assert
      final entity = model.toEntity();
      expect(entity, isA<KanjiList>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        // act
        final result = KanjiListModel.fromJson(tKanjiListJson);

        // assert
        expect(result.id, tKanjiListJson['id']);
        expect(result.name, tKanjiListJson['name']);
        expect(result.description, tKanjiListJson['description']);
        expect(result.userId, tKanjiListJson['userId']);
        expect(result.isPublic, tKanjiListJson['isPublic']);
        expect(
          result.createdAt,
          DateTime.parse(tKanjiListJson['createdAt'] as String),
        );
        expect(
          result.updatedAt,
          DateTime.parse(tKanjiListJson['updatedAt'] as String),
        );
        final userMap = tKanjiListJson['user'] as Map<String, dynamic>;
        expect(result.userName, userMap['account']);
        expect(result.userEmail, userMap['email']);
        expect(result.items.length, (tKanjiListJson['items'] as List).length);
      });

      test('should handle null description', () {
        // arrange
        final jsonWithoutDescription = Map<String, dynamic>.from(tKanjiListJson)
          ..['description'] = null;

        // act
        final result = KanjiListModel.fromJson(jsonWithoutDescription);

        // assert
        expect(result.description, isNull);
      });

      test('should handle empty items list', () {
        // arrange
        final jsonWithEmptyItems = Map<String, dynamic>.from(tKanjiListJson)
          ..['items'] = [];

        // act
        final result = KanjiListModel.fromJson(jsonWithEmptyItems);

        // assert
        expect(result.items, isEmpty);
      });

      test('should handle null items list', () {
        // arrange
        final jsonWithoutItems = Map<String, dynamic>.from(tKanjiListJson)
          ..remove('items');

        // act
        final result = KanjiListModel.fromJson(jsonWithoutItems);

        // assert
        expect(result.items, isEmpty);
      });

      test('should default userName to "Unknown" when user is null', () {
        // arrange
        final jsonWithoutUser = Map<String, dynamic>.from(tKanjiListJson)
          ..remove('user');

        // act
        final result = KanjiListModel.fromJson(jsonWithoutUser);

        // assert
        expect(result.userName, 'Unknown');
        expect(result.userEmail, isNull);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // arrange
        final model = KanjiListModel.fromJson(tKanjiListJson);

        // act
        final result = model.toJson();

        // assert
        expect(result['id'], model.id);
        expect(result['name'], model.name);
        expect(result['description'], model.description);
        expect(result['userId'], model.userId);
        expect(result['isPublic'], model.isPublic);
        expect(result['createdAt'], model.createdAt.toIso8601String());
        expect(result['updatedAt'], model.updatedAt.toIso8601String());
        expect(result['items'], isA<List>());
        expect(result['user'], isA<Map>());
        expect(result['user']['account'], model.userName);
        expect(result['user']['email'], model.userEmail);
      });

      test('should convert to JSON and back to model correctly', () {
        // arrange
        final model = KanjiListModel.fromJson(tKanjiListJson);

        // act
        final json = model.toJson();
        final newModel = KanjiListModel.fromJson(json);

        // assert
        expect(newModel.id, model.id);
        expect(newModel.name, model.name);
        expect(newModel.description, model.description);
        expect(newModel.userId, model.userId);
        expect(newModel.isPublic, model.isPublic);
        expect(newModel.createdAt, model.createdAt);
        expect(newModel.updatedAt, model.updatedAt);
        expect(newModel.items.length, model.items.length);
      });
    });

    group('toEntity', () {
      test('should convert model to entity correctly', () {
        // arrange
        final model = KanjiListModel.fromJson(tKanjiListJson);

        // act
        final entity = model.toEntity();

        // assert
        expect(entity.id, model.id);
        expect(entity.name, model.name);
        expect(entity.description, model.description);
        expect(entity.userId, model.userId);
        expect(entity.isPublic, model.isPublic);
        expect(entity.createdAt, model.createdAt);
        expect(entity.updatedAt, model.updatedAt);
        expect(entity.userName, model.userName);
        expect(entity.userEmail, model.userEmail);
        expect(entity.items.length, model.items.length);
      });

      test('should convert all items to entities', () {
        // arrange
        final model = KanjiListModel.fromJson(tKanjiListJson);

        // act
        final entity = model.toEntity();

        // assert
        for (int i = 0; i < entity.items.length; i++) {
          expect(entity.items[i].id, model.items[i].id);
          expect(entity.items[i].listId, model.items[i].listId);
          expect(entity.items[i].kanjiId, model.items[i].kanjiId);
          expect(entity.items[i].order, model.items[i].order);
          expect(entity.items[i].kanji.id, model.items[i].kanji.id);
        }
      });
    });
  });

  group('KanjiListItemModel', () {
    final tItemJson =
        (tKanjiListJson['items'] as List)[0] as Map<String, dynamic>;

    test('should parse from JSON correctly', () {
      // act
      final result = KanjiListItemModel.fromJson(tItemJson);

      // assert
      expect(result.id, tItemJson['id']);
      expect(result.listId, tItemJson['listId']);
      expect(result.kanjiId, tItemJson['kanjiId']);
      expect(result.order, tItemJson['order']);
      expect(result.kanji, isNotNull);
    });

    test('should convert to JSON correctly', () {
      // arrange
      final model = KanjiListItemModel.fromJson(tItemJson);

      // act
      final json = model.toJson();

      // assert
      expect(json['id'], model.id);
      expect(json['listId'], model.listId);
      expect(json['kanjiId'], model.kanjiId);
      expect(json['order'], model.order);
      expect(json['kanji'], isA<Map>());
    });

    test('should convert to entity correctly', () {
      // arrange
      final model = KanjiListItemModel.fromJson(tItemJson);

      // act
      final entity = model.toEntity();

      // assert
      expect(entity.id, model.id);
      expect(entity.listId, model.listId);
      expect(entity.kanjiId, model.kanjiId);
      expect(entity.order, model.order);
      expect(entity.kanji.id, model.kanji.id);
    });
  });

  group('KanjiListsResponse', () {
    test('should parse from JSON correctly', () {
      // act
      final result = KanjiListsResponse.fromJson(tAllKanjiListsResponseJson);

      // assert
      expect(
        result.data.length,
        (tAllKanjiListsResponseJson['data'] as List).length,
      );
      expect(result.total, tAllKanjiListsResponseJson['total']);
      expect(result.limit, tAllKanjiListsResponseJson['limit']);
      expect(result.offset, tAllKanjiListsResponseJson['offset']);
    });

    test('should parse all list items correctly', () {
      // act
      final result = KanjiListsResponse.fromJson(tAllKanjiListsResponseJson);

      // assert
      for (int i = 0; i < result.data.length; i++) {
        final jsonItem =
            (tAllKanjiListsResponseJson['data'] as List)[i]
                as Map<String, dynamic>;
        expect(result.data[i].id, jsonItem['id']);
        expect(result.data[i].name, jsonItem['name']);
      }
    });

    test('should handle empty data list', () {
      // arrange
      final emptyResponse = {'data': [], 'total': 0, 'limit': 20, 'offset': 0};

      // act
      final result = KanjiListsResponse.fromJson(emptyResponse);

      // assert
      expect(result.data, isEmpty);
      expect(result.total, 0);
    });
  });
}
