import 'package:equatable/equatable.dart';
import '../../models/kanji_recognition_result.dart';

abstract class KanjiRecognitionState extends Equatable {
  const KanjiRecognitionState();

  @override
  List<Object?> get props => [];
}

class KanjiRecognitionInitial extends KanjiRecognitionState {}

class KanjiRecognitionLoading extends KanjiRecognitionState {}

class KanjiRecognitionSuccess extends KanjiRecognitionState {
  final KanjiRecognitionResult result;

  const KanjiRecognitionSuccess(this.result);

  @override
  List<Object> get props => [result];
}

class KanjiRecognitionError extends KanjiRecognitionState {
  final String message;

  const KanjiRecognitionError(this.message);

  @override
  List<Object> get props => [message];
}
