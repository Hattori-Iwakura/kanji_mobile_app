import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kanji_flutter/core/error/failures.dart';
import 'package:kanji_flutter/features/kanji_recognition/domain/entities/kanji_recognition_result.dart';
import 'package:kanji_flutter/features/kanji_recognition/domain/usecases/recognize_kanji.dart';
import 'package:kanji_flutter/features/kanji_recognition/presentation/bloc/kanji_recognition_bloc.dart';
import 'package:kanji_flutter/features/kanji_recognition/presentation/bloc/kanji_recognition_event.dart';
import 'package:kanji_flutter/features/kanji_recognition/presentation/bloc/kanji_recognition_state.dart';

import 'kanji_recognition_bloc_test.mocks.dart';

@GenerateMocks([RecognizeKanji])
void main() {
  late KanjiRecognitionBloc kanjiRecognitionBloc;
  late MockRecognizeKanji mockRecognizeKanji;

  setUp(() {
    mockRecognizeKanji = MockRecognizeKanji();
    kanjiRecognitionBloc = KanjiRecognitionBloc(
      recognizeKanji: mockRecognizeKanji,
    );
  });

  tearDown(() {
    kanjiRecognitionBloc.close();
  });

  const tBase64Image = 'iVBORw0KGgoAAAANSUhEUgAAAAUA...';

  final tTop5 = [
    Top5Prediction(character: '日', confidence: 0.95),
    Top5Prediction(character: '目', confidence: 0.03),
    Top5Prediction(character: '口', confidence: 0.01),
    Top5Prediction(character: '白', confidence: 0.005),
    Top5Prediction(character: '田', confidence: 0.003),
  ];

  final tResult = KanjiRecognitionResult(
    character: '日',
    confidence: 0.95,
    top5: tTop5,
  );

  final lowConfidenceTop5 = [
    Top5Prediction(character: '日', confidence: 0.25),
    Top5Prediction(character: '目', confidence: 0.20),
    Top5Prediction(character: '口', confidence: 0.18),
    Top5Prediction(character: '白', confidence: 0.15),
    Top5Prediction(character: '田', confidence: 0.12),
  ];

  final lowConfidenceResult = KanjiRecognitionResult(
    character: '日',
    confidence: 0.25,
    top5: lowConfidenceTop5,
  );

  group('KanjiRecognitionBloc', () {
    test('initial state is KanjiRecognitionInitial', () {
      expect(kanjiRecognitionBloc.state, KanjiRecognitionInitial());
    });

    group('RecognizeKanjiEvent', () {
      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'emits [KanjiRecognitionLoading, KanjiRecognitionSuccess] when recognition succeeds',
        build: () {
          when(
            mockRecognizeKanji(tBase64Image),
          ).thenAnswer((_) async => Right(tResult));
          return kanjiRecognitionBloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent(tBase64Image)),
        expect: () => [
          KanjiRecognitionLoading(),
          KanjiRecognitionSuccess(tResult),
        ],
        verify: (_) {
          verify(mockRecognizeKanji(tBase64Image)).called(1);
        },
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'emits [KanjiRecognitionLoading, KanjiRecognitionSuccess] with top-5 predictions',
        build: () {
          when(
            mockRecognizeKanji(tBase64Image),
          ).thenAnswer((_) async => Right(tResult));
          return kanjiRecognitionBloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent(tBase64Image)),
        expect: () => [
          KanjiRecognitionLoading(),
          KanjiRecognitionSuccess(tResult),
        ],
        verify: (_) {
          final state = kanjiRecognitionBloc.state as KanjiRecognitionSuccess;
          expect(state.result.top5.length, 5);
          expect(state.result.character, '日');
          expect(state.result.confidence, 0.95);
        },
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'emits [KanjiRecognitionLoading, KanjiRecognitionError] when image is empty',
        build: () {
          when(mockRecognizeKanji('')).thenAnswer(
            (_) async => Left(ServerFailure('Image cannot be empty')),
          );
          return kanjiRecognitionBloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent('')),
        expect: () => [
          KanjiRecognitionLoading(),
          const KanjiRecognitionError('Image cannot be empty'),
        ],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'emits [KanjiRecognitionLoading, KanjiRecognitionError] when image format is invalid',
        build: () {
          when(mockRecognizeKanji('invalid-base64')).thenAnswer(
            (_) async => Left(ServerFailure('Invalid image format')),
          );
          return kanjiRecognitionBloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent('invalid-base64')),
        expect: () => [
          KanjiRecognitionLoading(),
          const KanjiRecognitionError('Invalid image format'),
        ],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'emits [KanjiRecognitionLoading, KanjiRecognitionError] when API connection fails',
        build: () {
          when(mockRecognizeKanji(tBase64Image)).thenAnswer(
            (_) async => Left(ServerFailure('Failed to connect to AI service')),
          );
          return kanjiRecognitionBloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent(tBase64Image)),
        expect: () => [
          KanjiRecognitionLoading(),
          const KanjiRecognitionError('Failed to connect to AI service'),
        ],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'emits [KanjiRecognitionLoading, KanjiRecognitionError] when timeout occurs',
        build: () {
          when(
            mockRecognizeKanji(tBase64Image),
          ).thenAnswer((_) async => Left(ServerFailure('Recognition timeout')));
          return kanjiRecognitionBloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent(tBase64Image)),
        expect: () => [
          KanjiRecognitionLoading(),
          const KanjiRecognitionError('Recognition timeout'),
        ],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'emits [KanjiRecognitionLoading, KanjiRecognitionError] when no kanji detected',
        build: () {
          when(mockRecognizeKanji(tBase64Image)).thenAnswer(
            (_) async => Left(ServerFailure('No kanji detected in image')),
          );
          return kanjiRecognitionBloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent(tBase64Image)),
        expect: () => [
          KanjiRecognitionLoading(),
          const KanjiRecognitionError('No kanji detected in image'),
        ],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'emits [KanjiRecognitionLoading, KanjiRecognitionSuccess] with low confidence predictions',
        build: () {
          when(
            mockRecognizeKanji(tBase64Image),
          ).thenAnswer((_) async => Right(lowConfidenceResult));
          return kanjiRecognitionBloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent(tBase64Image)),
        expect: () => [
          KanjiRecognitionLoading(),
          KanjiRecognitionSuccess(lowConfidenceResult),
        ],
      );
    });

    group('ClearRecognitionEvent', () {
      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'emits [KanjiRecognitionInitial] when clearing after successful recognition',
        build: () => kanjiRecognitionBloc,
        seed: () => KanjiRecognitionSuccess(tResult),
        act: (bloc) => bloc.add(ClearRecognitionEvent()),
        expect: () => [KanjiRecognitionInitial()],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'emits [KanjiRecognitionInitial] when clearing after error',
        build: () => kanjiRecognitionBloc,
        seed: () => const KanjiRecognitionError('Some error'),
        act: (bloc) => bloc.add(ClearRecognitionEvent()),
        expect: () => [KanjiRecognitionInitial()],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'emits [KanjiRecognitionInitial] when clearing from initial state',
        build: () => kanjiRecognitionBloc,
        act: (bloc) => bloc.add(ClearRecognitionEvent()),
        expect: () => [KanjiRecognitionInitial()],
      );
    });

    group('Multiple Events Sequence', () {
      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'handles multiple recognition attempts',
        build: () {
          when(mockRecognizeKanji(any)).thenAnswer((_) async => Right(tResult));
          return kanjiRecognitionBloc;
        },
        act: (bloc) {
          bloc.add(const RecognizeKanjiEvent(tBase64Image));
          return Future.delayed(const Duration(milliseconds: 100), () {
            bloc.add(ClearRecognitionEvent());
            return Future.delayed(const Duration(milliseconds: 100), () {
              bloc.add(const RecognizeKanjiEvent(tBase64Image));
            });
          });
        },
        expect: () => [
          KanjiRecognitionLoading(),
          KanjiRecognitionSuccess(tResult),
          KanjiRecognitionInitial(),
          KanjiRecognitionLoading(),
          KanjiRecognitionSuccess(tResult),
        ],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'handles recognition followed by immediate clear',
        build: () {
          when(
            mockRecognizeKanji(tBase64Image),
          ).thenAnswer((_) async => Right(tResult));
          return kanjiRecognitionBloc;
        },
        act: (bloc) {
          bloc.add(const RecognizeKanjiEvent(tBase64Image));
          return Future.delayed(const Duration(milliseconds: 100), () {
            bloc.add(ClearRecognitionEvent());
          });
        },
        expect: () => [
          KanjiRecognitionLoading(),
          KanjiRecognitionSuccess(tResult),
          KanjiRecognitionInitial(),
        ],
      );
    });
  });
}
