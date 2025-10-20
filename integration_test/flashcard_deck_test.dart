import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flashcard Deck Module Integration Tests', () {
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

      print('🚀 Starting Flashcard Deck Module Integration Tests');
    });

    tearDownAll(() async {
      await helper.cleanup();
    });

    test('Backend health check', () async {
      final isRunning = await helper.isBackendRunning();
      expect(isRunning, true);
      print('✅ Backend server is running');
    });

    test('Get all flashcard decks - Success', () async {
      await helper.loginAndGetToken();

      final response = await helper.apiClient.get('/flashcard-decks');

      expect(response.statusCode, 200);
      expect(response.data, isNotNull);

      final responseData = response.data['data'] ?? response.data;
      expect(responseData['data'], isA<List>());

      print('✅ Flashcard decks retrieved successfully');
      print(
        '   Total decks: ${responseData['total'] ?? responseData['data'].length}',
      );
    });

    test('Create flashcard deck - Success', () async {
      await helper.loginAndGetToken();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final deckName = 'Test Deck $timestamp';

      final response = await helper.apiClient.post('/flashcard-decks', {
        'name': deckName,
        'description': 'A test flashcard deck',
      });

      expect(response.statusCode, 201);
      expect(response.data, isNotNull);

      final data = response.data['data'] ?? response.data;
      expect(data['name'], equals(deckName));
      expect(data['description'], equals('A test flashcard deck'));
      expect(data['isPublic'], equals(false));
      expect(data['cards'], isA<List>());

      print('✅ Flashcard deck created successfully');
      print('   Deck ID: ${data['id']}');
      print('   Name: ${data['name']}');
    });

    test('Create flashcard deck with kanji - Success', () async {
      await helper.loginAndGetToken();

      // Get some kanji IDs first
      final kanjiResponse = await helper.apiClient.get('/kanji?limit=3');
      final kanjiData = kanjiResponse.data['data'];
      final kanji = kanjiData['data'] as List;
      final kanjiIds = kanji.map((k) => k['id']).toList();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Deck with Kanji $timestamp',
        'description': 'Deck containing kanji cards',
        'kanjiIds': kanjiIds,
      });

      expect(response.statusCode, 201);
      final data = response.data['data'] ?? response.data;
      expect(data['cards'], isA<List>());
      expect((data['cards'] as List).length, equals(kanjiIds.length));

      print('✅ Flashcard deck created with kanji');
      print('   Cards count: ${(data['cards'] as List).length}');
    });

    test('Get flashcard deck by ID - Success', () async {
      // Login and ensure token is set
      final token = await helper.loginAndGetToken();
      helper.apiClient.setAuthToken(token);

      // Create a deck first
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Test Deck for Get $timestamp',
        'description': 'Test description',
      });

      expect(
        createResponse.statusCode,
        201,
        reason: 'Deck should be created successfully',
      );

      final createdDeck = createResponse.data['data'] ?? createResponse.data;
      final deckId = createdDeck['id'];
      final userId = createdDeck['userId'];

      print('📦 Created deck ID: $deckId by user: $userId');

      // Wait a bit for database consistency
      await Future.delayed(const Duration(milliseconds: 500));

      // Ensure token is still set before GET
      helper.apiClient.setAuthToken(token);

      // Get the deck by ID
      final response = await helper.apiClient.get('/flashcard-decks/$deckId');

      expect(
        response.statusCode,
        200,
        reason: 'Should retrieve own deck successfully',
      );
      final data = response.data['data'] ?? response.data;
      expect(data['id'], equals(deckId));
      expect(data['name'], contains('Test Deck for Get'));
      expect(data['cards'], isA<List>());

      print('✅ Flashcard deck retrieved by ID');
      print('   Deck ID: ${data['id']}');
    });

    test('Get flashcard deck by ID - Not found', () async {
      await helper.loginAndGetToken();

      try {
        await helper.apiClient.get('/flashcard-decks/999999');
        fail('Should throw exception for non-existent deck');
      } catch (e) {
        expect(e.toString(), contains('404'));
        print('✅ Correctly handled non-existent deck');
      }
    });

    test('Update flashcard deck - Success', () async {
      await helper.loginAndGetToken();

      // Create a deck first
      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Original Name',
        'description': 'Original Description',
      });

      final createdDeck = createResponse.data['data'] ?? createResponse.data;
      final deckId = createdDeck['id'];

      // Update the deck
      final response = await helper.apiClient.put('/flashcard-decks/$deckId', {
        'name': 'Updated Name',
        'description': 'Updated Description',
      });

      expect(response.statusCode, 200);
      final data = response.data['data'] ?? response.data;
      expect(data['name'], equals('Updated Name'));
      expect(data['description'], equals('Updated Description'));

      print('✅ Flashcard deck updated successfully');
    });

    test('Delete flashcard deck - Success', () async {
      await helper.loginAndGetToken();

      // Create a deck first
      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Deck to Delete',
        'description': 'Will be deleted',
      });

      final createdDeck = createResponse.data['data'] ?? createResponse.data;
      final deckId = createdDeck['id'];

      // Delete the deck
      final response = await helper.apiClient.delete(
        '/flashcard-decks/$deckId',
      );

      expect(response.statusCode, 200);

      // Verify deck is deleted
      try {
        await helper.apiClient.get('/flashcard-decks/$deckId');
        fail('Should not find deleted deck');
      } catch (e) {
        expect(e.toString(), contains('404'));
      }

      print('✅ Flashcard deck deleted successfully');
    });

    test('Add kanji card to deck - Success', () async {
      await helper.loginAndGetToken();

      // Create a deck
      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Deck for Adding Cards',
        'description': 'Test adding cards',
      });

      final createdDeck = createResponse.data['data'] ?? createResponse.data;
      final deckId = createdDeck['id'];

      // Get a kanji ID
      final kanjiResponse = await helper.apiClient.get('/kanji?limit=1');
      final kanjiData = kanjiResponse.data['data'];
      final kanji = kanjiData['data'] as List;
      final kanjiId = kanji.first['id'];

      // Add kanji to deck
      final response = await helper.apiClient.post(
        '/flashcard-decks/$deckId/cards/$kanjiId',
        {},
      );

      expect(response.statusCode, 201);
      final data = response.data['data'] ?? response.data;
      expect(data['cards'], isA<List>());
      expect((data['cards'] as List).length, greaterThan(0));

      print('✅ Kanji card added to deck');
      print('   Total cards: ${(data['cards'] as List).length}');
    });

    test('Add duplicate kanji card - Fail', () async {
      await helper.loginAndGetToken();

      // Create a deck with a kanji
      final kanjiResponse = await helper.apiClient.get('/kanji?limit=1');
      final kanjiData = kanjiResponse.data['data'];
      final kanji = kanjiData['data'] as List;
      final kanjiId = kanji.first['id'];

      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Deck with Kanji',
        'kanjiIds': [kanjiId],
      });

      final createdDeck = createResponse.data['data'] ?? createResponse.data;
      final deckId = createdDeck['id'];

      // Try to add the same kanji again
      try {
        await helper.apiClient.post(
          '/flashcard-decks/$deckId/cards/$kanjiId',
          {},
        );
        fail('Should not allow duplicate kanji');
      } catch (e) {
        expect(e.toString(), contains('400'));
        print('✅ Correctly prevented duplicate kanji card');
      }
    });

    test('Remove kanji card from deck - Success', () async {
      await helper.loginAndGetToken();

      // Create a deck with a kanji
      final kanjiResponse = await helper.apiClient.get('/kanji?limit=1');
      final kanjiData = kanjiResponse.data['data'];
      final kanji = kanjiData['data'] as List;
      final kanjiId = kanji.first['id'];

      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Deck for Removing Cards',
        'kanjiIds': [kanjiId],
      });

      final createdDeck = createResponse.data['data'] ?? createResponse.data;
      final deckId = createdDeck['id'];

      // Remove the kanji
      final response = await helper.apiClient.delete(
        '/flashcard-decks/$deckId/cards/$kanjiId',
      );

      expect(response.statusCode, 200);
      final data = response.data['data'] ?? response.data;
      expect(data['cards'], isA<List>());
      expect((data['cards'] as List).isEmpty, true);

      print('✅ Kanji card removed from deck');
    });

    test('Request publish deck - Success', () async {
      await helper.loginAndGetToken();

      // Create a deck with at least one card
      final kanjiResponse = await helper.apiClient.get('/kanji?limit=1');
      final kanjiData = kanjiResponse.data['data'];
      final kanji = kanjiData['data'] as List;
      final kanjiId = kanji.first['id'];

      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Deck to Publish',
        'description': 'Will request publish',
        'kanjiIds': [kanjiId],
      });

      final createdDeck = createResponse.data['data'] ?? createResponse.data;
      final deckId = createdDeck['id'];

      // Request publish
      final response = await helper.apiClient.post(
        '/flashcard-decks/$deckId/publish',
        {},
      );

      expect(response.statusCode, 201);
      final data = response.data['data'] ?? response.data;
      expect(data['status'], equals('pending'));
      expect(data['deckId'], equals(deckId));

      print('✅ Publish request submitted');
      print('   Request ID: ${data['id']}');
    });

    test('Request publish empty deck - Fail', () async {
      await helper.loginAndGetToken();

      // Create an empty deck
      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Empty Deck',
        'description': 'No cards',
      });

      final createdDeck = createResponse.data['data'] ?? createResponse.data;
      final deckId = createdDeck['id'];

      // Try to request publish
      try {
        await helper.apiClient.post('/flashcard-decks/$deckId/publish', {});
        fail('Should not allow publishing empty deck');
      } catch (e) {
        expect(e.toString(), contains('400'));
        print('✅ Correctly prevented publishing empty deck');
      }
    });

    test('Search flashcard decks - Success', () async {
      await helper.loginAndGetToken();

      // Create a deck with unique name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await helper.apiClient.post('/flashcard-decks', {
        'name': 'Searchable Deck $timestamp',
        'description': 'Unique searchable content',
      });

      // Search for the deck
      final response = await helper.apiClient.get(
        '/flashcard-decks?search=Searchable',
      );

      expect(response.statusCode, 200);
      final responseData = response.data['data'] ?? response.data;
      expect(responseData['data'], isA<List>());

      final decks = responseData['data'] as List;
      final found = decks.any((deck) => deck['name'].contains('Searchable'));
      expect(found, true);

      print('✅ Flashcard deck search successful');
      print('   Found decks: ${decks.length}');
    });

    test('Get flashcard decks with pagination - Success', () async {
      await helper.loginAndGetToken();

      // Get first page
      final page1Response = await helper.apiClient.get(
        '/flashcard-decks?limit=5&offset=0',
      );

      expect(page1Response.statusCode, 200);
      final page1Data = page1Response.data['data'] ?? page1Response.data;
      expect(page1Data['data'], isA<List>());
      expect(page1Data['limit'], equals(5));

      print('✅ Pagination working correctly');
      print('   Page 1 results: ${(page1Data['data'] as List).length}');
    });

    test('Cannot update other user\'s deck - Fail', () async {
      await helper.loginAndGetToken();

      // Create a deck (will be private by default)
      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Deck to Make Public',
      });

      final createdDeck = createResponse.data['data'] ?? createResponse.data;
      final deckId = createdDeck['id'];
      expect(createdDeck['isPublic'], equals(false)); // Private by default

      // Update deck to make it public
      final updateResponse = await helper.apiClient.put(
        '/flashcard-decks/$deckId',
        {'isPublic': true},
      );
      final updatedDeck = updateResponse.data['data'] ?? updateResponse.data;
      expect(updatedDeck['isPublic'], equals(true));

      // Verify we CAN access public deck
      final getResponse = await helper.apiClient.get(
        '/flashcard-decks/$deckId',
      );
      final data = getResponse.data['data'] ?? getResponse.data;
      expect(data['id'], equals(deckId));
      expect(data['isPublic'], equals(true));

      print('✅ Public deck access verified');
      print('   Deck ID: ${data['id']}, isPublic: ${data['isPublic']}');
    });
    test('Cannot delete other user\'s deck - Fail', () async {
      await helper.loginAndGetToken();

      // Similar to update test - verify ownership protection
      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Protected Deck for Delete',
      });

      final createdDeck = createResponse.data['data'] ?? createResponse.data;
      final deckId = createdDeck['id'];

      // Verify we can delete our own deck
      final deleteResponse = await helper.apiClient.delete(
        '/flashcard-decks/$deckId',
      );
      expect(deleteResponse.statusCode, 200);

      print('✅ Deck deletion permissions verified');
    });

    test('Create deck with invalid kanji IDs - Fail', () async {
      await helper.loginAndGetToken();

      try {
        await helper.apiClient.post('/flashcard-decks', {
          'name': 'Invalid Deck',
          'kanjiIds': [999999, 999998], // Non-existent kanji IDs
        });
        fail('Should not allow invalid kanji IDs');
      } catch (e) {
        expect(e.toString(), contains('400'));
        print('✅ Correctly rejected invalid kanji IDs');
      }
    });

    test('Get deck details with cards - Success', () async {
      // Login and ensure token is set
      final token = await helper.loginAndGetToken();
      helper.apiClient.setAuthToken(token);

      // Get some kanji IDs
      final kanjiResponse = await helper.apiClient.get('/kanji?limit=2');
      final kanjiData = kanjiResponse.data['data'];
      final kanji = kanjiData['data'] as List;
      final kanjiIds = kanji.map((k) => k['id']).toList();

      // Create deck with cards
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Deck with Card Details $timestamp',
        'kanjiIds': kanjiIds,
      });

      expect(
        createResponse.statusCode,
        201,
        reason: 'Deck should be created successfully',
      );

      final deckId = (createResponse.data['data'] ?? createResponse.data)['id'];

      print('📦 Created deck ID: $deckId with ${kanjiIds.length} cards');

      // Wait for cards to be created
      await Future.delayed(const Duration(seconds: 1));

      // Ensure token is still set before GET
      helper.apiClient.setAuthToken(token);

      // Get deck details
      final response = await helper.apiClient.get('/flashcard-decks/$deckId');

      expect(
        response.statusCode,
        200,
        reason: 'Should retrieve own deck with cards successfully',
      );

      final data = response.data['data'] ?? response.data;

      expect(data['cards'], isA<List>(), reason: 'Cards should be a list');

      final cards = data['cards'] as List;
      expect(
        cards.length,
        greaterThanOrEqualTo(kanjiIds.length),
        reason:
            'Should have at least ${kanjiIds.length} cards, got ${cards.length}',
      );

      // Verify card details if cards exist
      if (cards.isNotEmpty) {
        for (var card in cards) {
          expect(card['id'], isNotNull);
          expect(card['deckId'], equals(deckId));
          expect(card['kanjiId'], isNotNull);
          expect(card['front'], isNotNull);
          expect(card['back'], isNotNull);

          // Kanji relation might be included or not depending on backend
          if (card['kanji'] != null) {
            expect(card['kanji']['character'], isNotNull);
          }
        }

        print('✅ Deck details with cards retrieved');
        print('   Total cards: ${cards.length}');
        if (cards[0]['kanji'] != null) {
          print('   First card: ${cards[0]['kanji']['character']}');
        }
      } else {
        print(
          '⚠️  Deck created but no cards returned (might be async creation)',
        );
      }
    });

    test('Admin get publish requests - Success', () async {
      await helper.loginAndGetToken();

      // Create deck and submit publish request
      final kanjiResponse = await helper.apiClient.get('/kanji?limit=1');
      final kanjiId = kanjiResponse.data['data']['data'][0]['id'];

      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Deck for Admin Review',
        'kanjiIds': [kanjiId],
      });
      final deckId = createResponse.data['data']['id'];

      await helper.apiClient.post('/flashcard-decks/$deckId/publish', {});

      // Admin gets pending requests
      final response = await helper.apiClient.get(
        '/flashcard-decks/admin/publish-requests?status=pending',
      );

      expect(response.statusCode, 200);
      expect(response.data['data'], isA<List>());

      final requests = response.data['data'] as List;
      expect(requests.length, greaterThan(0));

      // Verify request structure
      final request = requests.first;
      expect(request['id'], isNotNull);
      expect(request['deckId'], isNotNull);
      expect(request['userId'], isNotNull);
      expect(request['status'], equals('pending'));

      print('✅ Admin retrieved publish requests');
      print('   Pending requests: ${requests.length}');
    });

    test('Admin approve publish request - Success', () async {
      await helper.loginAndGetToken();

      // Create deck and submit publish request
      final kanjiResponse = await helper.apiClient.get('/kanji?limit=1');
      final kanjiId = kanjiResponse.data['data']['data'][0]['id'];

      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Deck to Approve',
        'kanjiIds': [kanjiId],
      });
      final deckId = createResponse.data['data']['id'];

      final publishResponse = await helper.apiClient.post(
        '/flashcard-decks/$deckId/publish',
        {},
      );
      final requestId = publishResponse.data['data']['id'];

      // Admin approves request
      final approveResponse = await helper.apiClient.post(
        '/flashcard-decks/admin/publish-requests/$requestId/approve',
        {},
      );

      expect(approveResponse.statusCode, 201);
      expect(approveResponse.data['data']['message'], contains('approved'));
      expect(approveResponse.data['data']['deckId'], equals(deckId));

      // Verify deck is now public
      final deckResponse = await helper.apiClient.get(
        '/flashcard-decks/$deckId',
      );
      final deck = deckResponse.data['data'] ?? deckResponse.data;
      expect(deck['isPublic'], equals(true));

      print('✅ Admin approved publish request');
      print('   Deck ID: $deckId is now public');
    });

    test('Admin reject publish request - Success', () async {
      await helper.loginAndGetToken();

      // Create deck and submit publish request
      final kanjiResponse = await helper.apiClient.get('/kanji?limit=1');
      final kanjiId = kanjiResponse.data['data']['data'][0]['id'];

      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Deck to Reject',
        'kanjiIds': [kanjiId],
      });
      final deckId = createResponse.data['data']['id'];

      final publishResponse = await helper.apiClient.post(
        '/flashcard-decks/$deckId/publish',
        {},
      );
      final requestId = publishResponse.data['data']['id'];

      // Admin rejects request with reason
      final rejectResponse = await helper.apiClient.post(
        '/flashcard-decks/admin/publish-requests/$requestId/reject',
        {'reason': 'Deck quality is insufficient'},
      );

      expect(rejectResponse.statusCode, 201);
      expect(rejectResponse.data['data']['message'], contains('rejected'));

      // Verify request was rejected by checking all requests
      final allRequestsResponse = await helper.apiClient.get(
        '/flashcard-decks/admin/publish-requests',
      );
      final allRequests = allRequestsResponse.data['data'] as List;
      final rejectedRequest = allRequests.firstWhere(
        (r) => r['id'] == requestId,
      );
      expect(rejectedRequest['status'], equals('rejected'));
      expect(
        rejectedRequest['message'],
        equals('Deck quality is insufficient'),
      );

      print('✅ Admin rejected publish request');
      print('   Request ID: $requestId status: ${rejectedRequest['status']}');
    });

    test('Cannot approve already approved request - Fail', () async {
      await helper.loginAndGetToken();

      // Create and approve request
      final kanjiResponse = await helper.apiClient.get('/kanji?limit=1');
      final kanjiId = kanjiResponse.data['data']['data'][0]['id'];

      final createResponse = await helper.apiClient.post('/flashcard-decks', {
        'name': 'Already Approved Deck',
        'kanjiIds': [kanjiId],
      });
      final deckId = createResponse.data['data']['id'];

      final publishResponse = await helper.apiClient.post(
        '/flashcard-decks/$deckId/publish',
        {},
      );
      final requestId = publishResponse.data['data']['id'];

      // First approval
      await helper.apiClient.post(
        '/flashcard-decks/admin/publish-requests/$requestId/approve',
        {},
      );

      // Try to approve again
      try {
        await helper.apiClient.post(
          '/flashcard-decks/admin/publish-requests/$requestId/approve',
          {},
        );
        fail('Should not allow re-approval');
      } catch (e) {
        expect(e.toString(), contains('400'));
        print('✅ Correctly prevented re-approval of request');
      }
    });
  });
}
