class NetworkException implements Exception {}

class UnAuthorizedException implements Exception {}

class ServerErrorException implements Exception {}

class ExceptionWithMessage implements Exception {
  final String message;

  ExceptionWithMessage({required this.message});

  @override
  String toString() {
    return 'ExceptionWithMessage: $message';
  }
}
