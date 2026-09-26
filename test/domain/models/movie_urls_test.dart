import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/domain/models/movie.dart';

void main() {
  test('Movie construit les URLs de ses images', () {
    const movie = Movie(
      id: 1,
      title: 'Film',
      overview: '',
      posterPath: '/poster.jpg',
      backdropPath: '/backdrop.jpg',
      releaseDate: '',
      voteAverage: 0,
      voteCount: 0,
    );

    expect(movie.fullPosterUrl, endsWith('/w500/poster.jpg'));
    expect(movie.fullBackdropUrl, endsWith('/original/backdrop.jpg'));
  });

  test('Movie retourne null sans image', () {
    const movie = Movie(
      id: 1,
      title: 'Film',
      overview: '',
      releaseDate: '',
      voteAverage: 0,
      voteCount: 0,
    );

    expect(movie.fullPosterUrl, isNull);
    expect(movie.fullBackdropUrl, isNull);
  });
}
