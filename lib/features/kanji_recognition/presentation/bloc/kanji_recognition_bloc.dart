import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/recognize_kanji.dart';
import 'kanji_recognition_event.dart';
import 'kanji_recognition_state.dart';

class KanjiRecognitionBloc
    extends Bloc<KanjiRecognitionEvent, KanjiRecognitionState> {
  final RecognizeKanji recognizeKanji;

  KanjiRecognitionBloc({required this.recognizeKanji})
    : super(KanjiRecognitionInitial()) {
    on<RecognizeKanjiEvent>(_onRecognizeKanji);
    on<ClearRecognitionEvent>(_onClearRecognition);
  }

  Future<void> _onRecognizeKanji(
    RecognizeKanjiEvent event,
    Emitter<KanjiRecognitionState> emit,
  ) async {
    emit(KanjiRecognitionLoading());

    final result = await recognizeKanji(event.base64Image);

    result.fold(
      (failure) => emit(KanjiRecognitionError(failure.message)),
      (recognitionResult) => emit(KanjiRecognitionSuccess(recognitionResult)),
    );
  }

  void _onClearRecognition(
    ClearRecognitionEvent event,
    Emitter<KanjiRecognitionState> emit,
  ) {
    emit(KanjiRecognitionInitial());
  }
}
