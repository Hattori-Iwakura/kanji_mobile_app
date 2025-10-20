import '../repositories/kanji_list_repository.dart';

class RequestPublishListUseCase {
  final KanjiListRepository repository;

  RequestPublishListUseCase(this.repository);

  Future<void> call(int listId) {
    return repository.requestPublish(listId);
  }
}
