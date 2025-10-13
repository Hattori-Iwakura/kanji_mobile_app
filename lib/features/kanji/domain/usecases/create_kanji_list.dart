import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kanji_list.dart';
import '../repositories/kanji_list_repository.dart';

class CreateKanjiList implements UseCase<KanjiList, CreateListParams> {
  final KanjiListRepository repository;

  CreateKanjiList(this.repository);

  @override
  Future<Either<Failure, KanjiList>> call(CreateListParams params) async {
    final newList = KanjiList(
      id: 0, // Will be assigned by database
      name: params.name,
      description: params.description,
      filterType: params.filterType,
      filterValue: params.filterValue,
      frequencyMin: params.frequencyMin,
      frequencyMax: params.frequencyMax,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      kanjiCount: 0,
    );

    return await repository.createList(newList);
  }
}

class CreateListParams {
  final String name;
  final String? description;
  final ListFilterType filterType;
  final int? filterValue;
  final int? frequencyMin;
  final int? frequencyMax;

  CreateListParams({
    required this.name,
    this.description,
    required this.filterType,
    this.filterValue,
    this.frequencyMin,
    this.frequencyMax,
  });
}
