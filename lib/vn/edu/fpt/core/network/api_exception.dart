class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.cause,
  });

  final int statusCode;
  final String message;
  final Object? cause;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
