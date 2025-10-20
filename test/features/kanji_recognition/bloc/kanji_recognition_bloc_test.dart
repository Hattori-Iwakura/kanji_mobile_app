import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:kanji_flutter/core/error/failures.dart';
import 'package:kanji_flutter/features/kanji_recognition/domain/usecases/recognize_kanji.dart';
import 'package:kanji_flutter/features/kanji_recognition/domain/entities/kanji_recognition_result.dart';
import 'package:kanji_flutter/features/kanji_recognition/presentation/bloc/kanji_recognition_bloc.dart';
import 'package:kanji_flutter/features/kanji_recognition/presentation/bloc/kanji_recognition_event.dart';
import 'package:kanji_flutter/features/kanji_recognition/presentation/bloc/kanji_recognition_state.dart';

@GenerateMocks([RecognizeKanji])
import 'kanji_recognition_bloc_test.mocks.dart';

void main() {
  late KanjiRecognitionBloc bloc;
  late MockRecognizeKanji mockRecognizeKanji;

  setUp(() {
    mockRecognizeKanji = MockRecognizeKanji();
    bloc = KanjiRecognitionBloc(recognizeKanji: mockRecognizeKanji);
  });

  tearDown(() {
    bloc.close();
  });

  final testResult = KanjiRecognitionResult(
    character: '一',
    confidence: 0.95,
    top5: [
      Top5Prediction(character: '一', confidence: 0.95),
      Top5Prediction(character: '二', confidence: 0.03),
      Top5Prediction(character: '三', confidence: 0.01),
      Top5Prediction(character: '十', confidence: 0.005),
      Top5Prediction(character: '七', confidence: 0.003),
    ],
  );

  group('KanjiRecognitionBloc Tests', () {
    test('initial state should be KanjiRecognitionInitial', () {
      expect(bloc.state, KanjiRecognitionInitial());
    });

    group('RecognizeKanjiEvent', () {
      const testBase64Image = 'data:image/png;base64,iVBORw0KGgoAAAANS';

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'should emit [Loading, Success] when recognition succeeds',
        build: () {
          when(
            mockRecognizeKanji(any),
          ).thenAnswer((_) async => Right(testResult));
          return bloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent(testBase64Image)),
        expect: () => [
          KanjiRecognitionLoading(),
          isA<KanjiRecognitionSuccess>()
              .having((s) => s.result.character, 'character', '一')
              .having((s) => s.result.confidence, 'confidence', 0.95)
              .having((s) => s.result.top5.length, 'top5 length', 5),
        ],
        verify: (_) {
          verify(mockRecognizeKanji(testBase64Image)).called(1);
        },
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'should emit [Loading, Error] when recognition fails',
        build: () {
          when(
            mockRecognizeKanji(any),
          ).thenAnswer((_) async => Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent(testBase64Image)),
        expect: () => [
          KanjiRecognitionLoading(),
          isA<KanjiRecognitionError>().having(
            (s) => s.message,
            'message',
            'Server error',
          ),
        ],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'should handle low confidence results',
        build: () {
          final lowConfidenceResult = KanjiRecognitionResult(
            character: '一',
            confidence: 0.15,
            top5: [
              Top5Prediction(character: '一', confidence: 0.15),
              Top5Prediction(character: '二', confidence: 0.14),
              Top5Prediction(character: '三', confidence: 0.13),
              Top5Prediction(character: '十', confidence: 0.12),
              Top5Prediction(character: '七', confidence: 0.11),
            ],
          );
          when(
            mockRecognizeKanji(any),
          ).thenAnswer((_) async => Right(lowConfidenceResult));
          return bloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent(testBase64Image)),
        expect: () => [
          KanjiRecognitionLoading(),
          isA<KanjiRecognitionSuccess>().having(
            (s) => s.result.confidence,
            'confidence',
            0.15,
          ),
        ],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'should handle network failure',
        build: () {
          when(mockRecognizeKanji(any)).thenAnswer(
            (_) async => Left(NetworkFailure('No internet connection')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const RecognizeKanjiEvent(testBase64Image)),
        expect: () => [
          KanjiRecognitionLoading(),
          isA<KanjiRecognitionError>().having(
            (s) => s.message,
            'message',
            contains('internet'),
          ),
        ],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'should handle multiple recognition requests',
        build: () {
          when(
            mockRecognizeKanji(any),
          ).thenAnswer((_) async => Right(testResult));
          return bloc;
        },
        act: (bloc) {
          bloc.add(const RecognizeKanjiEvent(testBase64Image));
          bloc.add(const RecognizeKanjiEvent(testBase64Image));
        },
        expect: () => [
          KanjiRecognitionLoading(),
          isA<KanjiRecognitionSuccess>(),
          KanjiRecognitionLoading(),
          isA<KanjiRecognitionSuccess>(),
        ],
      );
    });

    group('ClearRecognitionEvent', () {
      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'should emit Initial when clear is called',
        build: () => bloc,
        seed: () => KanjiRecognitionSuccess(testResult),
        act: (bloc) => bloc.add(ClearRecognitionEvent()),
        expect: () => [KanjiRecognitionInitial()],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'should emit Initial from Loading state',
        build: () => bloc,
        seed: () => KanjiRecognitionLoading(),
        act: (bloc) => bloc.add(ClearRecognitionEvent()),
        expect: () => [KanjiRecognitionInitial()],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'should emit Initial from Error state',
        build: () => bloc,
        seed: () => const KanjiRecognitionError('Some error'),
        act: (bloc) => bloc.add(ClearRecognitionEvent()),
        expect: () => [KanjiRecognitionInitial()],
      );

      blocTest<KanjiRecognitionBloc, KanjiRecognitionState>(
        'should remain Initial when already in Initial state',
        build: () => bloc,
        act: (bloc) => bloc.add(ClearRecognitionEvent()),
        expect: () => [KanjiRecognitionInitial()],
      );
    });
  });
}
