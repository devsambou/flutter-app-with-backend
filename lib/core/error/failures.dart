/// Échecs propagés au niveau de la couche Présentation
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, [this.statusCode]);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Erreur lors de la lecture du cache local',
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Mode hors-ligne : vérifiez votre connexion réseau',
  ]);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
