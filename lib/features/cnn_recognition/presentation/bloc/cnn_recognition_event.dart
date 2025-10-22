import 'package:equatable/equatable.dart';

/// Base event for CNN Recognition BLoC
abstract class CnnRecognitionEvent extends Equatable {
  const CnnRecognitionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to predict kanji from drawn image
class PredictKanjiEvent extends CnnRecognitionEvent {
  final List<int> imageBytes;

  const PredictKanjiEvent(this.imageBytes);

  @override
  List<Object> get props => [imageBytes];
}

/// Event to clear/reset recognition state
class ClearRecognitionEvent extends CnnRecognitionEvent {}

/// Event to check CNN server status
class CheckServerStatusEvent extends CnnRecognitionEvent {}
