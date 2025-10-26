import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/repositories/kanji_list_repository.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/update_kanji_list.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/kanji_list_fixtures.dart';

class MockKanjiListRepository extends Mock implements KanjiListRepository {}

void main() {
  late UpdateKanjiList usecase;
  late MockKanjiListRepository mockRepository;

  setUp(() {
    mockRepository = MockKanjiListRepository();
    usecase = UpdateKanjiList(mockRepository);
  });

  group('UpdateKanjiList', () {
    const tId = 1;
    const tName = 'Updated List';
    const tDescription = 'Updated description';
    const tIsPublic = true;

    test('should update kanji list with name only', () async {
      // arrange
      when(
        () => mockRepository.updateList(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenAnswer((_) async => Right(tKanjiList));

      // act
      final result = await usecase(id: tId, name: tName);

      // assert
      expect(result, Right(tKanjiList));
      verify(
        () => mockRepository.updateList(
          id: tId,
          name: tName,
          description: null,
          isPublic: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should update kanji list with description only', () async {
      // arrange
      when(
        () => mockRepository.updateList(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenAnswer((_) async => Right(tKanjiList));

      // act
      final result = await usecase(id: tId, description: tDescription);

      // assert
      expect(result, Right(tKanjiList));
      verify(
        () => mockRepository.updateList(
          id: tId,
          name: null,
          description: tDescription,
          isPublic: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should update kanji list with isPublic only', () async {
      // arrange
      when(
        () => mockRepository.updateList(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenAnswer((_) async => Right(tKanjiList));

      // act
      final result = await usecase(id: tId, isPublic: tIsPublic);

      // assert
      expect(result, Right(tKanjiList));
      verify(
        () => mockRepository.updateList(
          id: tId,
          name: null,
          description: null,
          isPublic: tIsPublic,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should update kanji list with all fields', () async {
      // arrange
      when(
        () => mockRepository.updateList(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenAnswer((_) async => Right(tKanjiList));

      // act
      final result = await usecase(
        id: tId,
        name: tName,
        description: tDescription,
        isPublic: tIsPublic,
      );

      // assert
      expect(result, Right(tKanjiList));
      verify(
        () => mockRepository.updateList(
          id: tId,
          name: tName,
          description: tDescription,
          isPublic: tIsPublic,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return BadRequestFailure when no fields provided', () async {
      // act
      final result = await usecase(id: tId);

      // assert
      expect(
        result,
        const Left(BadRequestFailure('At least one field must be provided')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return BadRequestFailure when name is empty', () async {
      // act
      final result = await usecase(id: tId, name: '');

      // assert
      expect(
        result,
        const Left(BadRequestFailure('List name cannot be empty')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test(
      'should return BadRequestFailure when name is only whitespace',
      () async {
        // act
        final result = await usecase(id: tId, name: '   ');

        // assert
        expect(
          result,
          const Left(BadRequestFailure('List name cannot be empty')),
        );
        verifyZeroInteractions(mockRepository);
      },
    );

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to update kanji list');
      when(
        () => mockRepository.updateList(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(id: tId, name: tName);

      // assert
      expect(result, const Left(tFailure));
      verify(
        () => mockRepository.updateList(
          id: tId,
          name: tName,
          description: null,
          isPublic: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
