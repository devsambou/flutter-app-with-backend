import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_vault/data/datasources/movie_local_data_source.dart';
import 'package:movie_vault/domain/models/movie.dart';

class MockBox extends Mock implements Box<dynamic> {}

void main() {
  late MockBox trendingBox;
  late MockBox detailsBox;
  late MovieLocalDataSourceImpl dataSource;

  const movie = Movie(
    id: 1,
    title: 'Film test',
    overview: 'Synopsis',
    posterPath: null,
    backdropPath: null,
    releaseDate: '2026-01-01',
    voteAverage: 7,
    voteCount: 10,
  );

  setUp(() {
    trendingBox = MockBox();
    detailsBox = MockBox();
    dataSource = MovieLocalDataSourceImpl(
      trendingBox: trendingBox,
      detailsBox: detailsBox,
      cacheTtl: const Duration(hours: 1),
    );
  });

  test('enregistre un horodatage avec les films mis en cache', () async {
    when(() => trendingBox.put(any(), any())).thenAnswer((_) async {});

    await dataSource.cacheTrendingMovies([movie]);

    final captured =
        verify(
              () => trendingBox.put('trending_page_1', captureAny()),
            ).captured.single
            as Map;
    expect(captured['cachedAt'], isA<String>());
    expect(captured['data'], isA<List>());
  });

  test('ignore un cache de films expiré', () async {
    when(() => trendingBox.get('trending_page_1')).thenReturn({
      'cachedAt': DateTime.now()
          .toUtc()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
      'data': [movie.toJson()],
    });

    final result = await dataSource.getCachedTrendingMovies();

    expect(result, isEmpty);
  });

  test(
    'ignore une ancienne entrée sans horodatage sans lever d erreur',
    () async {
      when(
        () => trendingBox.get('trending_page_1'),
      ).thenReturn([movie.toJson()]);

      final result = await dataSource.getCachedTrendingMovies();

      expect(result, isEmpty);
    },
  );
}
