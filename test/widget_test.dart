import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/domain/models/movie.dart';

void main() {
  test('Movie model serialization and getters test', () {
    final movie = Movie.fromJson({
      'id': 100,
      'title': 'Inception',
      'overview':
          'A thief who steals corporate secrets through the use of dream-sharing technology.',
      'poster_path': '/qmDpIHrmpJINaRKAfWQfftjCdyi.jpg',
      'backdrop_path': '/s3TBrRGB1iav7gFOCNx3H31MoES.jpg',
      'release_date': '2010-07-15',
      'vote_average': 8.8,
      'vote_count': 35000,
    });

    expect(movie.id, 100);
    expect(movie.title, 'Inception');
    expect(movie.voteAverage, 8.8);
    expect(movie.fullPosterUrl, contains('https://image.tmdb.org/t/p/w500'));
  });
}
