class QuizException implements Exception {
  final String message;
  final int? statusCode;

  QuizException({required this.message, this.statusCode});

  @override
  String toString() =>
      'QuizException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
