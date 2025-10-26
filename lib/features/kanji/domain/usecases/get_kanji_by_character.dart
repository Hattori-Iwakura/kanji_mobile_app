import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

/// Use case for getting a kanji by its character
/// Used in DRAWING type quiz questions to fetch kanji details
class GetKanjiByCharacter {
  final KanjiRepository repository;

  GetKanjiByCharacter(this.repository);

  /// Get kanji by character string
  ///
  /// Returns [Kanji] on success or [Failure] on error
  ///
  /// Example:
  /// ```dart
  /// final result = await getKanjiByCharacter('日');
  /// ```
  Future<Either<Failure, Kanji>> call(String character) async {
    if (character.isEmpty) {
      return Left(ValidationFailure('Character cannot be empty'));
    }

    if (character.length > 1) {
      return Left(ValidationFailure('Only single character is allowed'));
    }

    return await repository.getKanjiByCharacter(character);
  }
}
