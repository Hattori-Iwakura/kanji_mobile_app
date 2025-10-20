class KanjiListException implements Exception {
  final String message;

  KanjiListException(this.message);

  @override
  String toString() => 'KanjiListException: $message';
}
