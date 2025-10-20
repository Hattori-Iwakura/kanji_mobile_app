import '../repositories/kanji_list_repository.dart';

class RejectPublishRequestUseCase {
  final KanjiListRepository repository;

  RejectPublishRequestUseCase(this.repository);

  Future<void> call(int requestId, String? reason) {
    return repository.rejectPublishRequest(requestId, reason);
  }
}
