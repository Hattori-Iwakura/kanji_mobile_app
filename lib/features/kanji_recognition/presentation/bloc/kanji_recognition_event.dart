import 'package:equatable/equatable.dart';

abstract class KanjiRecognitionEvent extends Equatable {
  const KanjiRecognitionEvent();

  @override
  List<Object> get props => [];
}

class RecognizeKanjiEvent extends KanjiRecognitionEvent {
  final String base64Image;

  const RecognizeKanjiEvent(this.base64Image);

  @override
  List<Object> get props => [base64Image];
}

class ClearRecognitionEvent extends KanjiRecognitionEvent {}
