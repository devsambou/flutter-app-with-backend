import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/domain/models/movie_detail.dart';

void main() {
  test('CastMember lit et serialise ses donnees', () {
    final cast = CastMember.fromJson({
      'id': 4,
      'name': 'Acteur',
      'character': 'Personnage',
      'profile_path': '/profile.jpg',
    });

    expect(cast.id, 4);
    expect(cast.name, 'Acteur');
    expect(cast.toJson()['character'], 'Personnage');
    expect(cast.fullProfileUrl, contains('/w500/profile.jpg'));
  });
}
