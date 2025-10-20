import '../../domain/entities/flashcard_card_entity.dart';
import '../../domain/entities/flashcard_deck_entity.dart';
import '../../domain/entities/flashcard_exception.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/flashcard_remote_datasource.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final FlashcardRemoteDataSource remoteDataSource;

  FlashcardRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<FlashcardDeckEntity>> getAllDecks({
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final decks = await remoteDataSource.getAllDecks(
        search: search,
        limit: limit,
        offset: offset,
      );
      return decks.map((deck) => deck.toEntity()).toList();
    } on FlashcardException {
      rethrow;
    } catch (e) {
      throw FlashcardException('Failed to get flashcard decks: $e');
    }
  }

  @override
  Future<FlashcardDeckEntity> getDeckById(int id) async {
    try {
      final deck = await remoteDataSource.getDeckById(id);
      return deck.toEntity();
    } on FlashcardException {
      rethrow;
    } catch (e) {
      throw FlashcardException('Failed to get deck: $e');
    }
  }

  @override
  Future<FlashcardDeckEntity> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) async {
    try {
      final deck = await remoteDataSource.createDeck(
        name: name,
        description: description,
        kanjiIds: kanjiIds,
      );
      return deck.toEntity();
    } on FlashcardException {
      rethrow;
    } catch (e) {
      throw FlashcardException('Failed to create deck: $e');
    }
  }

  @override
  Future<FlashcardDeckEntity> updateDeck({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final deck = await remoteDataSource.updateDeck(
        id: id,
        name: name,
        description: description,
        isPublic: isPublic,
      );
      return deck.toEntity();
    } on FlashcardException {
      rethrow;
    } catch (e) {
      throw FlashcardException('Failed to update deck: $e');
    }
  }

  @override
  Future<void> deleteDeck(int id) async {
    try {
      await remoteDataSource.deleteDeck(id);
    } on FlashcardException {
      rethrow;
    } catch (e) {
      throw FlashcardException('Failed to delete deck: $e');
    }
  }

  @override
  Future<FlashcardCardEntity> addCard({
    required int deckId,
    required int kanjiId,
  }) async {
    try {
      final card = await remoteDataSource.addCard(
        deckId: deckId,
        kanjiId: kanjiId,
      );
      return card.toEntity();
    } on FlashcardException {
      rethrow;
    } catch (e) {
      throw FlashcardException('Failed to add card: $e');
    }
  }

  @override
  Future<void> removeCard({required int deckId, required int kanjiId}) async {
    try {
      await remoteDataSource.removeCard(deckId: deckId, kanjiId: kanjiId);
    } on FlashcardException {
      rethrow;
    } catch (e) {
      throw FlashcardException('Failed to remove card: $e');
    }
  }

  @override
  Future<void> requestPublish(int deckId) async {
    try {
      await remoteDataSource.requestPublish(deckId);
    } on FlashcardException {
      rethrow;
    } catch (e) {
      throw FlashcardException('Failed to request publish: $e');
    }
  }

  @override
  Future<List<dynamic>> getPublishRequests({String? status}) async {
    try {
      return await remoteDataSource.getPublishRequests(status: status);
    } on FlashcardException {
      rethrow;
    } catch (e) {
      throw FlashcardException('Failed to get publish requests: $e');
    }
  }

  @override
  Future<void> approvePublishRequest(int requestId) async {
    try {
      await remoteDataSource.approvePublishRequest(requestId);
    } on FlashcardException {
      rethrow;
    } catch (e) {
      throw FlashcardException('Failed to approve publish request: $e');
    }
  }

  @override
  Future<void> rejectPublishRequest(int requestId, String? reason) async {
    try {
      await remoteDataSource.rejectPublishRequest(requestId, reason);
    } on FlashcardException {
      rethrow;
    } catch (e) {
      throw FlashcardException('Failed to reject publish request: $e');
    }
  }
}
