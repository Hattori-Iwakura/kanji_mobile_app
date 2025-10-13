import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile/core/error/failures.dart';
import 'package:kanji_mobile/core/usecases/usecase.dart';
import 'package:kanji_mobile/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_mobile/features/kanji/domain/repositories/kanji_repository.dart';
import 'package:kanji_mobile/features/kanji/domain/usecases/get_all_kanji.dart';

// Mock Repository
class MockKanjiRepository implements KanjiRepository {
  @override
  Future<Either<Failure, List<Kanji>>> getAllKanji() async {
    return Right([
      const Kanji(
        id: 1,
        character: '一',
        strokes: 1,
        grade: 1,
        jlptNew: 5,
        meanings: ['One'],
        readingsOn: ['いち'],
        readingsKun: ['ひと'],
      ),
      const Kanji(
        id: 2,
        character: '二',
        strokes: 2,
        grade: 1,
        jlptNew: 5,
        meanings: ['Two'],
        readingsOn: ['に'],
        readingsKun: ['ふた'],
      ),
    ]);
  }

  @override
  Future<Either<Failure, Kanji>> getKanjiById(int id) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Kanji>>> getKanjiByGrade(int grade) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Kanji>>> getKanjiByJlptLevel(int level) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Kanji>>> searchKanji(String query) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Kanji>>> getKanjiByFrequency(
    int minFreq,
    int maxFreq,
  ) async {
    throw UnimplementedError();
  }
}

void main() {
  late GetAllKanji usecase;
  late MockKanjiRepository mockRepository;

  setUp(() {
    mockRepository = MockKanjiRepository();
    usecase = GetAllKanji(mockRepository);
  });

  test('should get all kanji from the repository', () async {
    // arrange
    // Mock repository already set up in setUp()

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result.isRight(), true);
    result.fold((failure) => fail('Should not return failure'), (kanjiList) {
      expect(kanjiList.length, 2);
      expect(kanjiList[0].character, '一');
      expect(kanjiList[1].character, '二');
    });
  });

  test('should return kanji with correct properties', () async {
    // act
    final result = await usecase(NoParams());

    // assert
    result.fold((failure) => fail('Should not return failure'), (kanjiList) {
      final firstKanji = kanjiList[0];
      expect(firstKanji.character, '一');
      expect(firstKanji.strokes, 1);
      expect(firstKanji.grade, 1);
      expect(firstKanji.jlptNew, 5);
      expect(firstKanji.meanings, contains('One'));
      expect(firstKanji.readingsOn, contains('いち'));
    });
  });
}
