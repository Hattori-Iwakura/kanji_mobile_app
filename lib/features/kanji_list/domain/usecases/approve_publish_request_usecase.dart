import '../repositories/kanji_list_repository.dart';

class ApprovePublishRequestUseCase {
  final KanjiListRepository repository;

  ApprovePublishRequestUseCase(this.repository);

  Future<void> call(int requestId) {
    return repository.approvePublishRequest(requestId);
  }
}
