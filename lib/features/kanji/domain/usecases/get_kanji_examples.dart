import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_example.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiExamplesUseCase {
  final KanjiRepository repository;

  GetKanjiExamplesUseCase(this.repository);

  Future<Either<Failure, List<KanjiExample>>> call(
    GetKanjiExamplesParams params,
  ) async {
    return await repository.getKanjiExamples(
      params.character,
      limit: params.limit,
    );
  }
}

class GetKanjiExamplesParams extends Equatable {
  final String character;
  final int? limit;

  const GetKanjiExamplesParams({required this.character, this.limit = 10});

  @override
  List<Object?> get props => [character, limit];
}
