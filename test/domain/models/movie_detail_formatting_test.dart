import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/domain/models/movie_detail.dart';

void main() {
  test('MovieDetail formate une duree en heures et minutes', () {
    const detail = MovieDetail(
      id: 1,
      title: 'Film',
      overview: '',
      releaseDate: '',
      voteAverage: 0,
      voteCount: 0,
      runtime: 125,
      genres: [],
    );

    expect(detail.formattedRuntime, '2h 5m');
  });

  test('MovieDetail affiche N/A sans duree', () {
    const detail = MovieDetail(
      id: 1,
      title: 'Film',
      overview: '',
      releaseDate: '',
      voteAverage: 0,
      voteCount: 0,
      genres: [],
    );

    expect(detail.formattedRuntime, 'N/A');
  });
}
