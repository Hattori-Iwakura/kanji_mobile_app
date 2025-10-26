import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/entities/kanji_list.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/repositories/kanji_list_repository.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/create_kanji_list.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/kanji_list_fixtures.dart';

class MockKanjiListRepository extends Mock implements KanjiListRepository {}

void main() {
  late CreateKanjiList usecase;
  late MockKanjiListRepository mockRepository;

  setUp(() {
    mockRepository = MockKanjiListRepository();
    usecase = CreateKanjiList(mockRepository);
  });

  group('CreateKanjiList', () {
    const tName = 'My JLPT N5 Kanji';
    const tDescription = 'Collection of N5 level kanji';
    const tKanjiIds = [1, 2, 3];

    test('should create kanji list with name only', () async {
      // arrange
      when(
        () => mockRepository.createList(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenAnswer((_) async => Right(tKanjiList));

      // act
      final result = await usecase(name: tName);

      // assert
      expect(result, Right(tKanjiList));
      verify(
        () => mockRepository.createList(
          name: tName,
          description: null,
          kanjiIds: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should create kanji list with name and description', () async {
      // arrange
      when(
        () => mockRepository.createList(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenAnswer((_) async => Right(tKanjiList));

      // act
      final result = await usecase(name: tName, description: tDescription);

      // assert
      expect(result, Right(tKanjiList));
      verify(
        () => mockRepository.createList(
          name: tName,
          description: tDescription,
          kanjiIds: null,
        ),
      ).called(1);
    });

    test(
      'should create kanji list with name, description and kanji IDs',
      () async {
        // arrange
        when(
          () => mockRepository.createList(
            name: any(named: 'name'),
            description: any(named: 'description'),
            kanjiIds: any(named: 'kanjiIds'),
          ),
        ).thenAnswer((_) async => Right(tKanjiList));

        // act
        final result = await usecase(
          name: tName,
          description: tDescription,
          kanjiIds: tKanjiIds,
        );

        // assert
        expect(result, Right(tKanjiList));
        verify(
          () => mockRepository.createList(
            name: tName,
            description: tDescription,
            kanjiIds: tKanjiIds,
          ),
        ).called(1);
      },
    );

    test('should return BadRequestFailure when name is empty', () async {
      // act
      final result = await usecase(name: '');

      // assert
      expect(result, Left(BadRequestFailure('List name cannot be empty')));
      verifyZeroInteractions(mockRepository);
    });

    test(
      'should return BadRequestFailure when name is only whitespace',
      () async {
        // act
        final result = await usecase(name: '   ');

        // assert
        expect(result, Left(BadRequestFailure('List name cannot be empty')));
        verifyZeroInteractions(mockRepository);
      },
    );

    test('should return ServerFailure when repository fails', () async {
      // arrange
      when(
        () => mockRepository.createList(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // act
      final result = await usecase(name: tName);

      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(
        () => mockRepository.createList(
          name: tName,
          description: null,
          kanjiIds: null,
        ),
      ).called(1);
    });

    test('should trim name before validation', () async {
      // arrange
      const nameWithSpaces = '  My List  ';
      when(
        () => mockRepository.createList(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenAnswer((_) async => Right(tKanjiList));

      // act
      final result = await usecase(name: nameWithSpaces);

      // assert
      expect(result, Right(tKanjiList));
      verify(
        () => mockRepository.createList(
          name: nameWithSpaces,
          description: null,
          kanjiIds: null,
        ),
      ).called(1);
    });
  });
}
