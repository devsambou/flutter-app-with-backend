import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_vault/data/datasources/movie_local_data_source.dart';

class MockClearBox extends Mock implements Box<dynamic> {}

void main() {
  test('clearCache vide les deux boites Hive', () async {
    final trending = MockClearBox();
    final details = MockClearBox();
    when(trending.clear).thenAnswer((_) async => 0);
    when(details.clear).thenAnswer((_) async => 0);
    final source = MovieLocalDataSourceImpl(
      trendingBox: trending,
      detailsBox: details,
    );

    await source.clearCache();

    verify(trending.clear).called(1);
    verify(details.clear).called(1);
  });
}
