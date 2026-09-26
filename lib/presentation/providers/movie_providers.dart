import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/network/tmdb_dio_client.dart';
import '../../data/datasources/movie_local_data_source.dart';
import '../../data/datasources/tmdb_remote_data_source.dart';
import '../../data/repositories/movie_repository.dart';
import '../../domain/models/movie.dart';
import '../../domain/models/movie_detail.dart';
import '../../domain/repositories/movie_repository_interface.dart';
import 'connectivity_provider.dart';

final tmdbDioClientProvider = Provider<TmdbDioClient>((ref) {
  return TmdbDioClient();
});

final trendingBoxProvider = Provider<Box>((ref) {
  return Hive.box(MovieLocalDataSourceImpl.trendingBoxName);
});

final detailsBoxProvider = Provider<Box>((ref) {
  return Hive.box(MovieLocalDataSourceImpl.detailsBoxName);
});

final movieLocalDataSourceProvider = Provider<MovieLocalDataSource>((ref) {
  final trendingBox = ref.watch(trendingBoxProvider);
  final detailsBox = ref.watch(detailsBoxProvider);
  return MovieLocalDataSourceImpl(
    trendingBox: trendingBox,
    detailsBox: detailsBox,
  );
});

final tmdbRemoteDataSourceProvider = Provider<TmdbRemoteDataSource>((ref) {
  final client = ref.watch(tmdbDioClientProvider);
  return TmdbRemoteDataSourceImpl(client);
});

final movieRepositoryProvider = Provider<MovieRepositoryInterface>((ref) {
  final remote = ref.watch(tmdbRemoteDataSourceProvider);
  final local = ref.watch(movieLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  return MovieRepository(
    remoteDataSource: remote,
    localDataSource: local,
    networkInfo: networkInfo,
  );
});

/// Provider des films populaires du moment
final trendingMoviesProvider = FutureProvider.autoDispose<List<Movie>>((
  ref,
) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getTrendingMovies();
});

/// Provider pour les détails d'un film spécifique par son ID
final movieDetailProvider = FutureProvider.autoDispose.family<MovieDetail, int>(
  (ref, movieId) async {
    final repository = ref.watch(movieRepositoryProvider);
    return repository.getMovieDetails(movieId);
  },
);

/// Chaîne de recherche réactive (Riverpod 2.x StateProvider)
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Résultats de recherche réactifs
final searchMoviesProvider = FutureProvider.autoDispose<List<Movie>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) {
    return [];
  }
  final repository = ref.watch(movieRepositoryProvider);
  return repository.searchMovies(query);
});
