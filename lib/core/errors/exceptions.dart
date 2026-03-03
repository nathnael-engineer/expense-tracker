class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
