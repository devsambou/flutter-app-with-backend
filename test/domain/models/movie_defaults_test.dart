import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/domain/models/movie.dart';

void main() {
  test('Movie applique ses valeurs par defaut', () {
    final movie = Movie.fromJson({});

    expect(movie.id, 0);
    expect(movie.title, 'Sans titre');
    expect(movie.overview, isEmpty);
    expect(movie.releaseDate, isEmpty);
    expect(movie.voteAverage, 0);
    expect(movie.voteCount, 0);
  });
}
