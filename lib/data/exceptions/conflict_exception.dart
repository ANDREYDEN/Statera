class ConflictException implements Exception {
  final String message;

  ConflictException(this.message);

  @override
  String toString() => message;
}
