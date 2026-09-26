import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/core/constants/api_constants.dart';

void main() {
  test('ApiConstants construit les endpoints de detail', () {
    expect(ApiConstants.movieDetail(42), '/movie/42');
    expect(ApiConstants.movieCredits(42), '/movie/42/credits');
    expect(ApiConstants.movieVideos(42), '/movie/42/videos');
  });

  test('ApiConstants expose les endpoints principaux', () {
    expect(ApiConstants.tmdbBaseUrl, startsWith('https://'));
    expect(ApiConstants.trendingMovies, contains('trending'));
    expect(ApiConstants.searchMovie, contains('search'));
  });
}
