import 'package:equatable/equatable.dart';

/// Example usage of a kanji character
class KanjiExample extends Equatable {
  final String japanese;
  final String meaning;
  final String? audioUrl;

  const KanjiExample({
    required this.japanese,
    required this.meaning,
    this.audioUrl,
  });

  @override
  List<Object?> get props => [japanese, meaning, audioUrl];
}
