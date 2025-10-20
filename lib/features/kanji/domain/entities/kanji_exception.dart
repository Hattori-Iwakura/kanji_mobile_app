class KanjiException implements Exception {
  final String message;

  KanjiException(this.message);

  @override
  String toString() => 'KanjiException: $message';
}
