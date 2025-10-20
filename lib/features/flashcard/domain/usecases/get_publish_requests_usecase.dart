import '../repositories/flashcard_repository.dart';

class GetPublishRequestsUseCase {
  final FlashcardRepository repository;

  GetPublishRequestsUseCase(this.repository);

  Future<List<dynamic>> call({String? status}) {
    return repository.getPublishRequests(status: status);
  }
}
