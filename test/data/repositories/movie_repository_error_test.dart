import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_vault/core/error/exceptions.dart';
import 'package:movie_vault/core/network/network_info.dart';
import 'package:movie_vault/data/datasources/movie_local_data_source.dart';
import 'package:movie_vault/data/datasources/tmdb_remote_data_source.dart';
import 'package:movie_vault/data/repositories/movie_repository.dart';
import 'package:movie_vault/domain/models/movie.dart';

class MockRemoteDataSource extends Mock implements TmdbRemoteDataSource {}

class MockLocalDataSource extends Mock implements MovieLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MovieRepository repository;
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late MockNetworkInfo network;

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
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    network = MockNetworkInfo();
    repository = MovieRepository(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: network,
    );
  });

  test('utilise le cache quand TMDB renvoie une erreur serveur', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(
      () => remote.fetchTrendingMovies(page: 1),
    ).thenThrow(const ServerException('TMDB indisponible', 503));
    when(
      () => local.getCachedTrendingMovies(page: 1),
    ).thenAnswer((_) async => [movie]);

    final result = await repository.getTrendingMovies();

    expect(result, [movie]);
  });

  test(
    'retourne une liste vide si TMDB et le cache sont indisponibles',
    () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(
        () => remote.fetchTrendingMovies(page: 1),
      ).thenThrow(const ServerException('TMDB indisponible', 503));
      when(
        () => local.getCachedTrendingMovies(page: 1),
      ).thenAnswer((_) async => []);

      final result = await repository.getTrendingMovies();

      expect(result, isEmpty);
    },
  );

  test('signale la recherche impossible sans réseau', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);

    expect(
      () => repository.searchMovies('Film'),
      throwsA(isA<NetworkException>()),
    );
    verifyZeroInteractions(remote);
  });
}
