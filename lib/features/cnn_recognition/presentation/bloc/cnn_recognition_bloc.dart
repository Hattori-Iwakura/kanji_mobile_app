import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/predict_kanji.dart';
import '../../domain/repositories/cnn_recognition_repository.dart';
import 'cnn_recognition_event.dart';
import 'cnn_recognition_state.dart';

/// BLoC for managing CNN kanji recognition
class CnnRecognitionBloc
    extends Bloc<CnnRecognitionEvent, CnnRecognitionState> {
  final PredictKanji predictKanji;
  final CnnRecognitionRepository repository;

  CnnRecognitionBloc({required this.predictKanji, required this.repository})
    : super(CnnRecognitionInitial()) {
    on<CheckServerStatusEvent>(_onCheckServerStatus);
    on<PredictKanjiEvent>(_onPredictKanji);
    on<ClearRecognitionEvent>(_onClearRecognition);
  }

  Future<void> _onCheckServerStatus(
    CheckServerStatusEvent event,
    Emitter<CnnRecognitionState> emit,
  ) async {
    emit(CheckingServerStatus());

    final result = await repository.checkServerStatus();

    result.fold((failure) => emit(ServerUnavailable(failure.message)), (
      isAvailable,
    ) {
      if (isAvailable) {
        emit(ServerAvailable());
      } else {
        emit(
          const ServerUnavailable(
            'CNN server is not responding. Please ensure the FastAPI server is running at http://10.0.2.2:8000',
          ),
        );
      }
    });
  }

  Future<void> _onPredictKanji(
    PredictKanjiEvent event,
    Emitter<CnnRecognitionState> emit,
  ) async {
    emit(PredictingKanji());

    final result = await predictKanji(event.imageBytes);

    result.fold((failure) => emit(PredictionError(failure.message)), (
      predictions,
    ) {
      if (predictions.isEmpty) {
        emit(
          const PredictionError(
            'No kanji recognized. Please try drawing clearer.',
          ),
        );
      } else {
        emit(PredictionSuccess(predictions));
      }
    });
  }

  Future<void> _onClearRecognition(
    ClearRecognitionEvent event,
    Emitter<CnnRecognitionState> emit,
  ) async {
    emit(CnnRecognitionInitial());
  }
}
