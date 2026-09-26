import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/domain/models/movie_detail.dart';

void main() {
  test('MovieDetail lit les valeurs minimales TMDB', () {
    final detail = MovieDetail.fromJson({'id': 7, 'title': 'Film'});

    expect(detail.id, 7);
    expect(detail.title, 'Film');
    expect(detail.overview, isEmpty);
    expect(detail.genres, isEmpty);
    expect(detail.cast, isEmpty);
  });
}
