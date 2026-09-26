import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/domain/models/movie.dart';

void main() {
  test('Movie accepte les champs TMDB des series', () {
    final movie = Movie.fromJson({
      'id': 8,
      'name': 'Serie test',
      'first_air_date': '2024-01-02',
      'vote_average': 8.25,
      'vote_count': 12,
    });

    expect(movie.title, 'Serie test');
    expect(movie.releaseDate, '2024-01-02');
    expect(movie.voteAverage, 8.25);
  });
}
