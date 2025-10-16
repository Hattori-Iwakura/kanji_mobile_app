import 'package:equatable/equatable.dart';
import '../../../domain/entities/kanji_detail.dart';
import '../../../domain/entities/kanji_example.dart';

abstract class KanjiDetailState extends Equatable {
  const KanjiDetailState();

  @override
  List<Object?> get props => [];
}

class DetailInitial extends KanjiDetailState {
  const DetailInitial();
}

class DetailLoading extends KanjiDetailState {
  const DetailLoading();
}

class DetailLoaded extends KanjiDetailState {
  final KanjiDetail detail;
  final List<KanjiExample> allExamples;

  const DetailLoaded({required this.detail, required this.allExamples});

  DetailLoaded copyWith({
    KanjiDetail? detail,
    List<KanjiExample>? allExamples,
  }) {
    return DetailLoaded(
      detail: detail ?? this.detail,
      allExamples: allExamples ?? this.allExamples,
    );
  }

  @override
  List<Object?> get props => [detail, allExamples];
}

class DetailLoadingMore extends KanjiDetailState {
  final KanjiDetail detail;
  final List<KanjiExample> currentExamples;

  const DetailLoadingMore({
    required this.detail,
    required this.currentExamples,
  });

  @override
  List<Object?> get props => [detail, currentExamples];
}

class DetailError extends KanjiDetailState {
  final String message;

  const DetailError(this.message);

  @override
  List<Object?> get props => [message];
}
