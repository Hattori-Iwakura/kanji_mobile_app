import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/kanji_repository.dart';

class DeleteKanji {
  final KanjiRepository repository;

  DeleteKanji(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteKanji(id);
  }
}
