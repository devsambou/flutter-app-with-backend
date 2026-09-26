import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_vault/core/error/exceptions.dart';
import 'package:movie_vault/core/network/network_info.dart';
import 'package:movie_vault/data/datasources/movie_local_data_source.dart';
import 'package:movie_vault/data/datasources/tmdb_remote_data_source.dart';
import 'package:movie_vault/data/repositories/movie_repository.dart';
import 'package:movie_vault/domain/models/movie_detail.dart';

class MockDetailsRemoteDataSource extends Mock
    implements TmdbRemoteDataSource {}

class MockDetailsLocalDataSource extends Mock implements MovieLocalDataSource {}

class MockDetailsNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MovieRepository repository;
  late MockDetailsRemoteDataSource remote;
  late MockDetailsLocalDataSource local;
  late MockDetailsNetworkInfo network;

  const detail = MovieDetail(
    id: 550,
    title: 'Fight Club',
    overview: 'Synopsis',
    releaseDate: '1999-10-15',
    voteAverage: 8.4,
    voteCount: 100,
    genres: ['Drame'],
  );

  setUp(() {
    remote = MockDetailsRemoteDataSource();
    local = MockDetailsLocalDataSource();
    network = MockDetailsNetworkInfo();
    repository = MovieRepository(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: network,
    );
  });

  test('retourne le détail mis en cache hors ligne', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);
    when(() => local.getCachedMovieDetail(550)).thenAnswer((_) async => detail);

    final result = await repository.getMovieDetails(550);

    expect(result, detail);
    verifyZeroInteractions(remote);
  });

  test('signale un détail indisponible hors ligne sans cache', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);
    when(() => local.getCachedMovieDetail(550)).thenAnswer((_) async => null);

    expect(
      () => repository.getMovieDetails(550),
      throwsA(isA<NetworkException>()),
    );
    verifyZeroInteractions(remote);
  });
}
