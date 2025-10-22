import 'package:equatable/equatable.dart';
import '../../domain/entities/prediction_result.dart';

/// Base state for CNN Recognition BLoC
abstract class CnnRecognitionState extends Equatable {
  const CnnRecognitionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CnnRecognitionInitial extends CnnRecognitionState {}

/// State when checking server status
class CheckingServerStatus extends CnnRecognitionState {}

/// State when server is available
class ServerAvailable extends CnnRecognitionState {}

/// State when server is unavailable
class ServerUnavailable extends CnnRecognitionState {
  final String message;

  const ServerUnavailable(this.message);

  @override
  List<Object> get props => [message];
}

/// State when prediction is in progress
class PredictingKanji extends CnnRecognitionState {}

/// State when predictions are loaded successfully
class PredictionSuccess extends CnnRecognitionState {
  final List<PredictionResult> predictions;

  const PredictionSuccess(this.predictions);

  @override
  List<Object> get props => [predictions];

  /// Get top prediction
  PredictionResult get topPrediction => predictions.first;

  /// Check if top prediction has high confidence
  bool get hasHighConfidence => topPrediction.isHighConfidence;
}

/// State when prediction fails
class PredictionError extends CnnRecognitionState {
  final String message;

  const PredictionError(this.message);

  @override
  List<Object> get props => [message];
}
