import '../repositories/kanji_list_repository.dart';

class GetPublishRequestsUseCase {
  final KanjiListRepository repository;

  GetPublishRequestsUseCase(this.repository);

  Future<List<dynamic>> call({String? status}) {
    return repository.getPublishRequests(status: status);
  }
}
