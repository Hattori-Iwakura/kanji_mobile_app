import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiByCharacterUseCase {
  final KanjiRepository repository;

  GetKanjiByCharacterUseCase(this.repository);

  Future<Either<Failure, Kanji>> call(String character) async {
    return await repository.getKanjiByCharacter(character);
  }
}
