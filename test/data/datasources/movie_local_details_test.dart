import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_vault/data/datasources/movie_local_data_source.dart';
import 'package:movie_vault/domain/models/movie_detail.dart';

class MockDetailsBox extends Mock implements Box<dynamic> {}

void main() {
  late MockDetailsBox detailsBox;
  late MovieLocalDataSourceImpl dataSource;

  const detail = MovieDetail(
    id: 5,
    title: 'Film',
    overview: 'Synopsis',
    releaseDate: '',
    voteAverage: 7,
    voteCount: 1,
    genres: [],
  );

  setUp(() {
    detailsBox = MockDetailsBox();
    dataSource = MovieLocalDataSourceImpl(
      trendingBox: MockDetailsBox(),
      detailsBox: detailsBox,
    );
  });

  test('cache et relit un detail frais', () async {
    when(() => detailsBox.put(any(), any())).thenAnswer((_) async {});
    await dataSource.cacheMovieDetail(detail);
    final payload =
        verify(() => detailsBox.put(5, captureAny())).captured.single as Map;
    when(() => detailsBox.get(5)).thenReturn(payload);

    final result = await dataSource.getCachedMovieDetail(5);

    expect(result?.id, detail.id);
    expect(result?.title, detail.title);
    expect(result?.overview, detail.overview);
    expect(result?.genres, detail.genres);
  });

  test('retourne null quand le detail est absent', () async {
    when(() => detailsBox.get(5)).thenReturn(null);

    expect(await dataSource.getCachedMovieDetail(5), isNull);
  });
}
