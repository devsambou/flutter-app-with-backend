/// Exceptions levées au niveau de la couche Data
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Aucune connexion internet détectée']);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthExceptionApp implements Exception {
  final String message;

  const AuthExceptionApp(this.message);

  @override
  String toString() => 'AuthExceptionApp: $message';
}
