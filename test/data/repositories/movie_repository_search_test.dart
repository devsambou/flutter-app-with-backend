import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_vault/core/error/exceptions.dart';
import 'package:movie_vault/core/network/network_info.dart';
import 'package:movie_vault/data/datasources/movie_local_data_source.dart';
import 'package:movie_vault/data/datasources/tmdb_remote_data_source.dart';
import 'package:movie_vault/data/repositories/movie_repository.dart';
import 'package:movie_vault/domain/models/movie.dart';

class MockSearchRemoteDataSource extends Mock implements TmdbRemoteDataSource {}

class MockSearchLocalDataSource extends Mock implements MovieLocalDataSource {}

class MockSearchNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MovieRepository repository;
  late MockSearchRemoteDataSource remote;
  late MockSearchNetworkInfo network;

  const movie = Movie(
    id: 3,
    title: 'Resultat',
    overview: '',
    releaseDate: '',
    voteAverage: 6,
    voteCount: 2,
  );

  setUp(() {
    remote = MockSearchRemoteDataSource();
    network = MockSearchNetworkInfo();
    repository = MovieRepository(
      remoteDataSource: remote,
      localDataSource: MockSearchLocalDataSource(),
      networkInfo: network,
    );
  });

  test('retourne les resultats de recherche distants', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(
      () => remote.searchMovies('Dune', page: 2),
    ).thenAnswer((_) async => [movie]);

    final result = await repository.searchMovies('Dune', page: 2);

    expect(result, [movie]);
    verify(() => remote.searchMovies('Dune', page: 2)).called(1);
  });

  test('refuse une recherche hors ligne', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);

    expect(
      () => repository.searchMovies('Dune'),
      throwsA(isA<NetworkException>()),
    );
    verifyZeroInteractions(remote);
  });
}
