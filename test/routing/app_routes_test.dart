import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/routing/app_routes.dart';

void main() {
  test('AppRoutes construit le chemin detail avec un identifiant', () {
    expect(AppRoutes.movieDetailPath(99), '/movie/99');
  });

  test('AppRoutes contient les routes publiques attendues', () {
    expect(AppRoutes.login, '/login');
    expect(AppRoutes.register, '/register');
    expect(AppRoutes.search, '/search');
  });
}
