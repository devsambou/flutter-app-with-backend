import 'package:flutter/foundation.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/models/movie.dart';
import '../../domain/models/movie_detail.dart';
import '../../domain/repositories/movie_repository_interface.dart';
import '../datasources/movie_local_data_source.dart';
import '../datasources/tmdb_remote_data_source.dart';

/// Repository orchestrant l'accès aux données de films.
/// Il applique une stratégie offline-first avec mise en cache Hive
/// et fallback automatique si le réseau est indisponible.
class MovieRepository implements MovieRepositoryInterface {
  final TmdbRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MovieRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Movie>> getTrendingMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      debugPrint(
        'ℹ️ [MovieRepository] Hors-ligne : lecture du cache pour trending (page $page)',
      );
      final cached = await localDataSource.getCachedTrendingMovies(page: page);
      if (cached.isNotEmpty) {
        return cached;
      }
      throw const NetworkException(
        'Mode hors-ligne : aucun film enregistré en cache local.',
      );
    }

    try {
      final remoteMovies = await remoteDataSource.fetchTrendingMovies(
        page: page,
      );
      // Mise en cache en arrière-plan
      await localDataSource.cacheTrendingMovies(remoteMovies, page: page);
      return remoteMovies;
    } on ServerException catch (_) {
      // Fallback sur le cache si l'API distante échoue
      final cached = await localDataSource.getCachedTrendingMovies(page: page);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<MovieDetail> getMovieDetails(
    int movieId, {
    bool forceRefresh = false,
  }) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      debugPrint(
        'ℹ️ [MovieRepository] Hors-ligne : lecture du cache pour le film #$movieId',
      );
      final cached = await localDataSource.getCachedMovieDetail(movieId);
      if (cached != null) {
        return cached;
      }
      throw NetworkException(
        'Mode hors-ligne : les détails du film #$movieId n\'ont pas encore été mis en cache.',
      );
    }

    try {
      final remoteDetail = await remoteDataSource.fetchMovieDetails(movieId);
      await localDataSource.cacheMovieDetail(remoteDetail);
      return remoteDetail;
    } on ServerException catch (_) {
      final cached = await localDataSource.getCachedMovieDetail(movieId);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      throw const NetworkException(
        'La recherche nécessite une connexion internet active.',
      );
    }

    return await remoteDataSource.searchMovies(query, page: page);
  }
}
