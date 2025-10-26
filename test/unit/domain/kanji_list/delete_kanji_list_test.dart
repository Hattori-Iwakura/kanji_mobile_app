import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/repositories/kanji_list_repository.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/delete_kanji_list.dart';
import 'package:mocktail/mocktail.dart';

class MockKanjiListRepository extends Mock implements KanjiListRepository {}

void main() {
  late DeleteKanjiList usecase;
  late MockKanjiListRepository mockRepository;

  setUp(() {
    mockRepository = MockKanjiListRepository();
    usecase = DeleteKanjiList(mockRepository);
  });

  group('DeleteKanjiList', () {
    const tId = 1;

    test('should delete kanji list by id', () async {
      // arrange
      when(
        () => mockRepository.deleteList(any()),
      ).thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.deleteList(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when list does not exist', () async {
      // arrange
      const tFailure = NotFoundFailure('Kanji list not found');
      when(
        () => mockRepository.deleteList(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.deleteList(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return UnauthorizedFailure when user is not owner', () async {
      // arrange
      const tFailure = UnauthorizedFailure(
        'You are not authorized to delete this list',
      );
      when(
        () => mockRepository.deleteList(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.deleteList(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to delete kanji list');
      when(
        () => mockRepository.deleteList(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.deleteList(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
