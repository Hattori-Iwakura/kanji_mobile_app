class FlashcardException implements Exception {
  final String message;

  FlashcardException(this.message);

  @override
  String toString() => 'FlashcardException: $message';
}
