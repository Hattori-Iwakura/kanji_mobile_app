import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji/data/datasources/kanji_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/kanji/data/models/kanji_model.dart';
import 'package:kanji_mobile_v1/features/kanji/data/repositories/kanji_repository_impl.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/entities/kanji.dart';

import '../../../helpers/fixtures/kanji_fixtures.dart';

class MockKanjiRemoteDataSource extends Mock implements KanjiRemoteDataSource {}

void main() {
  late KanjiRepositoryImpl repository;
  late MockKanjiRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockKanjiRemoteDataSource();
    repository = KanjiRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('KanjiRepositoryImpl', () {
    group('getAllKanji', () {
      final tKanjiModels = [
        KanjiModel.fromEntity(tKanji1),
        KanjiModel.fromEntity(tKanji2),
      ];

      test(
        'should return list of kanji when remote call is successful',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.getAllKanji(
              jlpt: any(named: 'jlpt'),
              grade: any(named: 'grade'),
              search: any(named: 'search'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenAnswer((_) async => tKanjiModels);

          // act
          final result = await repository.getAllKanji();

          // assert
          expect(result, isA<Right<Failure, List<Kanji>>>());
          result.fold((failure) => fail('Should return Right'), (kanji) {
            expect(kanji.length, 2);
            expect(kanji[0].id, tKanji1.id);
            expect(kanji[1].id, tKanji2.id);
          });
          verify(
            () => mockRemoteDataSource.getAllKanji(
              jlpt: null,
              grade: null,
              search: null,
              limit: null,
              offset: null,
            ),
          ).called(1);
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test('should return kanji filtered by JLPT level', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getAllKanji(
            jlpt: any(named: 'jlpt'),
            grade: any(named: 'grade'),
            search: any(named: 'search'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [KanjiModel.fromEntity(tKanji1)]);

        // act
        final result = await repository.getAllKanji(jlpt: 5);

        // assert
        expect(result, isA<Right<Failure, List<Kanji>>>());
        verify(
          () => mockRemoteDataSource.getAllKanji(
            jlpt: 5,
            grade: null,
            search: null,
            limit: null,
            offset: null,
          ),
        ).called(1);
      });

      test('should return NetworkFailure when timeout occurs', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getAllKanji(
            jlpt: any(named: 'jlpt'),
            grade: any(named: 'grade'),
            search: any(named: 'search'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('Connection timeout'));

        // act
        final result = await repository.getAllKanji();

        // assert
        expect(result, isA<Left<Failure, List<Kanji>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (kanji) => fail('Should return Left'),
        );
      });

      test('should return ServerFailure when server error occurs', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getAllKanji(
            jlpt: any(named: 'jlpt'),
            grade: any(named: 'grade'),
            search: any(named: 'search'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('Server error: 500'));

        // act
        final result = await repository.getAllKanji();

        // assert
        expect(result, isA<Left<Failure, List<Kanji>>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (kanji) => fail('Should return Left'),
        );
      });
    });

    group('getKanjiById', () {
      final tKanjiModel = KanjiModel.fromEntity(tKanji1);

      test('should return kanji when remote call is successful', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getKanjiById(any()),
        ).thenAnswer((_) async => tKanjiModel);

        // act
        final result = await repository.getKanjiById(1);

        // assert
        expect(result, isA<Right<Failure, Kanji>>());
        result.fold((failure) => fail('Should return Right'), (kanji) {
          expect(kanji.id, tKanji1.id);
          expect(kanji.character, tKanji1.character);
        });
        verify(() => mockRemoteDataSource.getKanjiById(1)).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return NotFoundFailure when kanji does not exist', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getKanjiById(any()),
        ).thenThrow(Exception('Not found'));

        // act
        final result = await repository.getKanjiById(999);

        // assert
        expect(result, isA<Left<Failure, Kanji>>());
        result.fold(
          (failure) => expect(failure, isA<NotFoundFailure>()),
          (kanji) => fail('Should return Left'),
        );
      });

      test('should return UnauthorizedFailure when auth fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getKanjiById(any()),
        ).thenThrow(Exception('Unauthorized'));

        // act
        final result = await repository.getKanjiById(1);

        // assert
        expect(result, isA<Left<Failure, Kanji>>());
        result.fold(
          (failure) => expect(failure, isA<UnauthorizedFailure>()),
          (kanji) => fail('Should return Left'),
        );
      });
    });

    group('getKanjiByCharacter', () {
      final tKanjiModel = KanjiModel.fromEntity(tKanji1);

      test('should return kanji when remote call is successful', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getKanjiByCharacter(any()),
        ).thenAnswer((_) async => tKanjiModel);

        // act
        final result = await repository.getKanjiByCharacter('日');

        // assert
        expect(result, isA<Right<Failure, Kanji>>());
        result.fold((failure) => fail('Should return Right'), (kanji) {
          expect(kanji.character, '日');
        });
        verify(() => mockRemoteDataSource.getKanjiByCharacter('日')).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return NotFoundFailure when character not found', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getKanjiByCharacter(any()),
        ).thenThrow(Exception('Not found'));

        // act
        final result = await repository.getKanjiByCharacter('X');

        // assert
        expect(result, isA<Left<Failure, Kanji>>());
        result.fold(
          (failure) => expect(failure, isA<NotFoundFailure>()),
          (kanji) => fail('Should return Left'),
        );
      });
    });

    group('searchKanji', () {
      final tKanjiModels = [
        KanjiModel.fromEntity(tKanji1),
        KanjiModel.fromEntity(tKanji2),
      ];

      test(
        'should return search results when remote call is successful',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.searchKanji(
              query: any(named: 'query'),
              jlptLevels: any(named: 'jlptLevels'),
              grades: any(named: 'grades'),
              minStrokes: any(named: 'minStrokes'),
              maxStrokes: any(named: 'maxStrokes'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              sortBy: any(named: 'sortBy'),
            ),
          ).thenAnswer((_) async => tKanjiModels);

          // act
          final result = await repository.searchKanji(query: 'sun');

          // assert
          expect(result, isA<Right<Failure, List<Kanji>>>());
          result.fold(
            (failure) => fail('Should return Right'),
            (kanji) => expect(kanji.length, 2),
          );
          verify(
            () => mockRemoteDataSource.searchKanji(
              query: 'sun',
              jlptLevels: null,
              grades: null,
              minStrokes: null,
              maxStrokes: null,
              page: 1,
              limit: 20,
              sortBy: null,
            ),
          ).called(1);
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test('should search with multiple filters', () async {
        // arrange
        when(
          () => mockRemoteDataSource.searchKanji(
            query: any(named: 'query'),
            jlptLevels: any(named: 'jlptLevels'),
            grades: any(named: 'grades'),
            minStrokes: any(named: 'minStrokes'),
            maxStrokes: any(named: 'maxStrokes'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            sortBy: any(named: 'sortBy'),
          ),
        ).thenAnswer((_) async => [KanjiModel.fromEntity(tKanji1)]);

        // act
        final result = await repository.searchKanji(
          query: 'sun',
          jlptLevels: [5, 4],
          grades: [1, 2],
          minStrokes: 1,
          maxStrokes: 5,
        );

        // assert
        expect(result, isA<Right<Failure, List<Kanji>>>());
        verify(
          () => mockRemoteDataSource.searchKanji(
            query: 'sun',
            jlptLevels: [5, 4],
            grades: [1, 2],
            minStrokes: 1,
            maxStrokes: 5,
            page: 1,
            limit: 20,
            sortBy: null,
          ),
        ).called(1);
      });

      test('should return BadRequestFailure when request is invalid', () async {
        // arrange
        when(
          () => mockRemoteDataSource.searchKanji(
            query: any(named: 'query'),
            jlptLevels: any(named: 'jlptLevels'),
            grades: any(named: 'grades'),
            minStrokes: any(named: 'minStrokes'),
            maxStrokes: any(named: 'maxStrokes'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            sortBy: any(named: 'sortBy'),
          ),
        ).thenThrow(Exception('Bad request'));

        // act
        final result = await repository.searchKanji(query: '');

        // assert
        expect(result, isA<Left<Failure, List<Kanji>>>());
        result.fold(
          (failure) => expect(failure, isA<BadRequestFailure>()),
          (kanji) => fail('Should return Left'),
        );
      });
    });
  });
}
