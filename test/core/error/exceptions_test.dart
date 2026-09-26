import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/core/error/exceptions.dart';

void main() {
  test('les exceptions exposent un message exploitable', () {
    expect(
      const ServerException('Serveur', 503).toString(),
      contains('Serveur'),
    );
    expect(const CacheException('Cache').toString(), contains('Cache'));
    expect(const NetworkException('Reseau').toString(), contains('Reseau'));
    expect(const AuthExceptionApp('Auth').toString(), contains('Auth'));
  });
}
