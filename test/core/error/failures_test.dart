import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/core/error/failures.dart';

void main() {
  test('les failures conservent leur message', () {
    expect(const ServerFailure('Serveur', 500).message, 'Serveur');
    expect(const CacheFailure().message, contains('cache'));
    expect(const NetworkFailure().message, contains('hors-ligne'));
    expect(const AuthFailure('Connexion').toString(), 'Connexion');
  });
}
