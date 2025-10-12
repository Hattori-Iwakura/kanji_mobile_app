import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class SearchKanji implements UseCase<List<Kanji>, SearchParams> {
  final KanjiRepository repository;

  SearchKanji(this.repository);

  @override
  Future<Either<Failure, List<Kanji>>> call(SearchParams params) async {
    return await repository.searchKanji(params.query);
  }
}

class SearchParams {
  final String query;

  SearchParams({required this.query});
}
