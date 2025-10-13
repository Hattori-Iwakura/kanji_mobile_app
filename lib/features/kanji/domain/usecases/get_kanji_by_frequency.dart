import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiByFrequency implements UseCase<List<Kanji>, FrequencyParams> {
  final KanjiRepository repository;

  GetKanjiByFrequency(this.repository);

  @override
  Future<Either<Failure, List<Kanji>>> call(FrequencyParams params) async {
    return await repository.getKanjiByFrequency(params.minFreq, params.maxFreq);
  }
}

class FrequencyParams {
  final int minFreq;
  final int maxFreq;

  FrequencyParams({required this.minFreq, required this.maxFreq});
}
