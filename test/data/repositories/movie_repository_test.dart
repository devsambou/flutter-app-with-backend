import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_vault/core/error/exceptions.dart';
import 'package:movie_vault/core/network/network_info.dart';
import 'package:movie_vault/data/datasources/movie_local_data_source.dart';
import 'package:movie_vault/data/datasources/tmdb_remote_data_source.dart';
import 'package:movie_vault/data/repositories/movie_repository.dart';
import 'package:movie_vault/domain/models/movie.dart';
import 'package:movie_vault/domain/models/movie_detail.dart';

class MockTmdbRemoteDataSource extends Mock implements TmdbRemoteDataSource {}

class MockMovieLocalDataSource extends Mock implements MovieLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class FakeMovieDetail extends Fake implements MovieDetail {}

void main() {
  late MovieRepository repository;
  late MockTmdbRemoteDataSource mockRemoteDataSource;
  late MockMovieLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUpAll(() {
    registerFallbackValue(FakeMovieDetail());
  });

  setUp(() {
    mockRemoteDataSource = MockTmdbRemoteDataSource();
    mockLocalDataSource = MockMovieLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = MovieRepository(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tMovie = Movie(
    id: 550,
    title: 'Fight Club',
    overview: 'Un employé de bureau insomniaque...',
    posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    backdropPath: '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
    releaseDate: '1999-10-15',
    voteAverage: 8.4,
    voteCount: 26000,
  );

  const tMovieDetail = MovieDetail(
    id: 550,
    title: 'Fight Club',
    overview: 'Un employé de bureau insomniaque...',
    posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    backdropPath: '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
    releaseDate: '1999-10-15',
    voteAverage: 8.4,
    voteCount: 26000,
    runtime: 139,
    tagline: 'Mischief. Mayhem. Soap.',
    genres: ['Drame', 'Thriller'],
    cast: [
      CastMember(
        id: 287,
        name: 'Brad Pitt',
        character: 'Tyler Durden',
        profilePath: '/cckcYc2v0yh1tc9QjRelptsqpHW.jpg',
      ),
    ],
    trailerKey: 'qtRKdVHc-cE',
  );

  group('MovieRepository - getTrendingMovies', () {
    test(
      'doit récupérer les films distants et les mettre en cache si le réseau est disponible',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.fetchTrendingMovies(page: 1),
        ).thenAnswer((_) async => [tMovie]);
        when(
          () => mockLocalDataSource.cacheTrendingMovies(any(), page: 1),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.getTrendingMovies(page: 1);

        // Assert
        expect(result, equals([tMovie]));
        verify(() => mockNetworkInfo.isConnected).called(1);
        verify(
          () => mockRemoteDataSource.fetchTrendingMovies(page: 1),
        ).called(1);
        verify(
          () => mockLocalDataSource.cacheTrendingMovies([tMovie], page: 1),
        ).called(1);
      },
    );

    test(
      'doit retourner les films depuis le cache Hive en mode hors-ligne',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(
          () => mockLocalDataSource.getCachedTrendingMovies(page: 1),
        ).thenAnswer((_) async => [tMovie]);

        // Act
        final result = await repository.getTrendingMovies(page: 1);

        // Assert
        expect(result, equals([tMovie]));
        verify(() => mockNetworkInfo.isConnected).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
        verify(
          () => mockLocalDataSource.getCachedTrendingMovies(page: 1),
        ).called(1);
      },
    );

    test(
      'doit lever NetworkException en mode hors-ligne si le cache est vide',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(
          () => mockLocalDataSource.getCachedTrendingMovies(page: 1),
        ).thenAnswer((_) async => []);

        // Act & Assert
        expect(
          () => repository.getTrendingMovies(page: 1),
          throwsA(isA<NetworkException>()),
        );
        verifyZeroInteractions(mockRemoteDataSource);
      },
    );
  });

  group('MovieRepository - getMovieDetails', () {
    test(
      'doit retourner les détails distants et les cacher quand connecté',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.fetchMovieDetails(550),
        ).thenAnswer((_) async => tMovieDetail);
        when(
          () => mockLocalDataSource.cacheMovieDetail(any()),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.getMovieDetails(550);

        // Assert
        expect(result.id, equals(550));
        expect(result.title, equals('Fight Club'));
        verify(() => mockRemoteDataSource.fetchMovieDetails(550)).called(1);
        verify(
          () => mockLocalDataSource.cacheMovieDetail(tMovieDetail),
        ).called(1);
      },
    );

    test('doit retourner les détails en cache si hors-ligne', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockLocalDataSource.getCachedMovieDetail(550),
      ).thenAnswer((_) async => tMovieDetail);

      // Act
      final result = await repository.getMovieDetails(550);

      // Assert
      expect(result.id, equals(550));
      verifyZeroInteractions(mockRemoteDataSource);
      verify(() => mockLocalDataSource.getCachedMovieDetail(550)).called(1);
    });
  });

  group('MovieRepository - searchMovies', () {
    test(
      'doit appeler la recherche distante lorsque le réseau est connecté',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.searchMovies('Fight', page: 1),
        ).thenAnswer((_) async => [tMovie]);

        // Act
        final result = await repository.searchMovies('Fight', page: 1);

        // Assert
        expect(result, equals([tMovie]));
        verify(
          () => mockRemoteDataSource.searchMovies('Fight', page: 1),
        ).called(1);
      },
    );

    test(
      'doit retourner une liste vide immédiatement si la requête est vide',
      () async {
        // Act
        final result = await repository.searchMovies('   ');

        // Assert
        expect(result, isEmpty);
        verifyZeroInteractions(mockRemoteDataSource);
      },
    );
  });
}
