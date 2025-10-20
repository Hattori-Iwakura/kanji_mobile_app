import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Kanji List Module Integration Tests', () {
    late IntegrationTestHelper helper;
    int? createdListId;

    setUpAll(() async {
      helper = IntegrationTestHelper();

      final isRunning = await helper.isBackendRunning();
      if (!isRunning) {
        throw Exception(
          'Backend server is not running! '
          'Please start it with: cd kanji-web-be && npm run start:dev',
        );
      }

      await helper.registerTestUser();
      await helper.loginAndGetToken();
    });

    tearDownAll(() async {
      // Cleanup: Delete created test list
      if (createdListId != null) {
        try {
          await helper.apiClient.delete('/kanji-lists/$createdListId');
          print('🧹 Cleaned up test list: $createdListId');
        } catch (e) {
          print('⚠️ Failed to cleanup test list: $e');
        }
      }
      await helper.cleanup();
    });

    test('Get all kanji lists - Success', () async {
      final response = await helper.apiClient.get('/kanji-lists');

      expect(response.statusCode, 200);
      expect(response.data, isNotNull);

      // Extract nested data
      final responseData = response.data['data'] ?? response.data;
      final lists = responseData['data'] as List;

      expect(lists, isA<List>());

      print('✅ Kanji lists retrieved successfully');
      print('   Total lists: ${responseData['total']}');

      // Should have system lists (N5-N1) - system lists have userId = null
      final systemLists = lists
          .where((list) => list['userId'] == null)
          .toList();
      expect(systemLists.length, greaterThanOrEqualTo(5));

      print('   System lists: ${systemLists.length}');
    });

    test('Get kanji lists by type - System lists', () async {
      final response = await helper.apiClient.get('/kanji-lists?type=system');

      expect(response.statusCode, 200);

      final responseData = response.data['data'] ?? response.data;
      final lists = responseData['data'] as List;

      expect(lists, isA<List>());

      for (final list in lists) {
        // System lists have userId = null
        expect(list['userId'], isNull);
      }

      print('✅ System lists filtered successfully');
    });

    test('Get kanji lists by type - Custom lists', () async {
      final response = await helper.apiClient.get('/kanji-lists?type=custom');

      expect(response.statusCode, 200);

      final responseData = response.data['data'] ?? response.data;
      final lists = responseData['data'] as List;

      expect(lists, isA<List>());

      for (final list in lists) {
        // Custom lists have userId (not null)
        expect(list['userId'], isNotNull);
      }

      print('✅ Custom lists filtered successfully');
      print('   Custom lists count: ${lists.length}');
    });

    test('Create custom kanji list - Success', () async {
      final testListName = 'Test List ${DateTime.now().millisecondsSinceEpoch}';

      final response = await helper.apiClient.post('/kanji-lists', {
        'name': testListName,
        'description': 'Integration test list',
      });

      expect(response.statusCode, 201);

      final listData = response.data['data'] ?? response.data;

      expect(listData, isNotNull);
      expect(listData['id'], isNotNull);
      expect(listData['name'], equals(testListName));
      expect(listData['isPublic'], equals(false));

      createdListId = listData['id'];

      print('✅ Custom list created successfully');
      print('   ID: $createdListId');
      print('   Name: ${listData['name']}');
    });

    test('Get kanji list by ID - Success', () async {
      expect(createdListId, isNotNull, reason: 'List should be created first');

      final response = await helper.apiClient.get(
        '/kanji-lists/$createdListId',
      );

      expect(response.statusCode, 200);

      final listData = response.data['data'] ?? response.data;

      expect(listData['id'], equals(createdListId));
      expect(listData['items'], isA<List>());

      print('✅ Kanji list detail retrieved successfully');
    });

    test('Update kanji list - Success', () async {
      expect(createdListId, isNotNull);

      final newName = 'Updated Test List';
      final response = await helper.apiClient.patch(
        '/kanji-lists/$createdListId',
        {'name': newName, 'description': 'Updated description'},
      );

      expect(response.statusCode, 200);

      final listData = response.data['data'] ?? response.data;

      expect(listData['name'], equals(newName));
      expect(listData['description'], equals('Updated description'));

      print('✅ Kanji list updated successfully');
    });

    test('Add kanji to list - Success', () async {
      expect(createdListId, isNotNull);

      // Get a kanji ID first
      final kanjiResponse = await helper.apiClient.get('/kanji?limit=1');
      final kanjiData = kanjiResponse.data['data'] ?? kanjiResponse.data;
      final kanjiList = kanjiData['data'] as List;
      final kanjiId = kanjiList[0]['id'];

      final response = await helper.apiClient.post(
        '/kanji-lists/$createdListId/kanji/$kanjiId',
        {},
      );

      expect(response.statusCode, 201); // Backend returns 201 Created

      // Verify kanji was added
      final listResponse = await helper.apiClient.get(
        '/kanji-lists/$createdListId',
      );
      final listData = listResponse.data['data'] ?? listResponse.data;
      final items = listData['items'] as List;

      expect(
        items.any((item) => item['kanjiId'] == kanjiId),
        true,
        reason: 'Kanji should be in the list',
      );

      print('✅ Kanji added to list successfully');
      print('   Kanji ID: $kanjiId');
    });

    test('Add duplicate kanji to list - Conflict', () async {
      expect(createdListId, isNotNull);

      // Get the first kanji in the list
      final listResponse = await helper.apiClient.get(
        '/kanji-lists/$createdListId',
      );
      final listData = listResponse.data['data'] ?? listResponse.data;
      final items = listData['items'] as List;

      expect(items.isNotEmpty, true);

      final kanjiId = items[0]['kanjiId'];

      try {
        await helper.apiClient.post(
          '/kanji-lists/$createdListId/kanji/$kanjiId',
          {},
        );
        fail('Should throw exception for duplicate kanji');
      } catch (e) {
        expect(
          e.toString(),
          contains('400'),
        ); // Backend returns 400 Bad Request
        print('✅ Correctly rejected duplicate kanji');
      }
    });

    test('Remove kanji from list - Success', () async {
      expect(createdListId, isNotNull);

      // Get the first kanji in the list
      final listResponse = await helper.apiClient.get(
        '/kanji-lists/$createdListId',
      );
      final listData = listResponse.data['data'] ?? listResponse.data;
      final items = listData['items'] as List;

      expect(items.isNotEmpty, true);

      final kanjiId = items[0]['kanjiId'];

      final response = await helper.apiClient.delete(
        '/kanji-lists/$createdListId/kanji/$kanjiId',
      );

      expect(response.statusCode, 200);

      // Verify kanji was removed
      final updatedListResponse = await helper.apiClient.get(
        '/kanji-lists/$createdListId',
      );
      final updatedListData =
          updatedListResponse.data['data'] ?? updatedListResponse.data;
      final updatedItems = updatedListData['items'] as List;

      expect(
        updatedItems.any((item) => item['kanjiId'] == kanjiId),
        false,
        reason: 'Kanji should be removed from the list',
      );

      print('✅ Kanji removed from list successfully');
    });

    test('Cannot modify system lists', () async {
      // Get a system list
      final response = await helper.apiClient.get('/kanji-lists?type=system');
      final responseData = response.data['data'] ?? response.data;
      final lists = responseData['data'] as List;

      expect(lists.isNotEmpty, true);

      final systemListId = lists[0]['id'];

      try {
        await helper.apiClient.patch('/kanji-lists/$systemListId', {
          'name': 'Hacked System List',
        });
        fail('Should not be able to modify system list');
      } catch (e) {
        expect(e.toString(), contains('403'));
        print('✅ System list protected from modification');
      }
    });

    test('Delete custom list - Success', () async {
      // Create a new list to delete
      final response = await helper.apiClient.post('/kanji-lists', {
        'name': 'List to Delete',
      });
      final listData = response.data['data'] ?? response.data;
      final listIdToDelete = listData['id'];

      final deleteResponse = await helper.apiClient.delete(
        '/kanji-lists/$listIdToDelete',
      );

      expect(deleteResponse.statusCode, 200);

      // Verify list was deleted
      try {
        await helper.apiClient.get('/kanji-lists/$listIdToDelete');
        fail('List should be deleted');
      } catch (e) {
        expect(e.toString(), contains('404'));
      }

      print('✅ Kanji list deleted successfully');
    });

    test('Cannot delete system list', () async {
      final response = await helper.apiClient.get('/kanji-lists?type=system');
      final responseData = response.data['data'] ?? response.data;
      final lists = responseData['data'] as List;

      final systemListId = lists[0]['id'];

      try {
        await helper.apiClient.delete('/kanji-lists/$systemListId');
        fail('Should not be able to delete system list');
      } catch (e) {
        expect(e.toString(), contains('403'));
        print('✅ System list protected from deletion');
      }
    });
  });
}
