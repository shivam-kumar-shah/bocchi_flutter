class ApiException implements Exception {
  final String message;
  final String error;
  ApiException({
    required this.message,
    required this.error,
  });

  @override
  String toString() {
    return message;
  }

  String get getBaseError {
    return error;
  }
}
