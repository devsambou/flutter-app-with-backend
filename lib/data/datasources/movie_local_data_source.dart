import 'package:hive_flutter/hive_flutter.dart';
import '../../core/error/exceptions.dart';
import '../../domain/models/movie.dart';
import '../../domain/models/movie_detail.dart';

abstract class MovieLocalDataSource {
  Future<void> cacheTrendingMovies(List<Movie> movies, {int page = 1});
  Future<List<Movie>> getCachedTrendingMovies({int page = 1});

  Future<void> cacheMovieDetail(MovieDetail movieDetail);
  Future<MovieDetail?> getCachedMovieDetail(int movieId);

  Future<void> clearCache();
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  static const String trendingBoxName = 'trending_movies_cache';
  static const String detailsBoxName = 'movie_details_cache';
  static const Duration defaultCacheTtl = Duration(hours: 24);

  final Box trendingBox;
  final Box detailsBox;
  final Duration cacheTtl;

  MovieLocalDataSourceImpl({
    required this.trendingBox,
    required this.detailsBox,
    this.cacheTtl = defaultCacheTtl,
  });

  @override
  Future<void> cacheTrendingMovies(List<Movie> movies, {int page = 1}) async {
    try {
      final jsonList = movies.map((m) => m.toJson()).toList();
      await trendingBox.put('trending_page_$page', {
        'cachedAt': DateTime.now().toUtc().toIso8601String(),
        'data': jsonList,
      });
    } catch (e) {
      throw CacheException(
        'Impossible de mettre en cache les films populaires : $e',
      );
    }
  }

  @override
  Future<List<Movie>> getCachedTrendingMovies({int page = 1}) async {
    try {
      final rawValue = trendingBox.get('trending_page_$page');
      if (rawValue == null) {
        return [];
      }
      if (rawValue is! Map) {
        return [];
      }
      final rawMap = Map<String, dynamic>.from(rawValue as Map);
      final cachedAt = DateTime.tryParse(rawMap['cachedAt'] as String? ?? '');
      if (cachedAt == null ||
          DateTime.now().toUtc().difference(cachedAt) > cacheTtl) {
        return [];
      }
      final list = (rawMap['data'] as List)
          .map((item) => Movie.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      return list;
    } catch (e) {
      throw CacheException(
        'Erreur de lecture du cache des films populaires : $e',
      );
    }
  }

  @override
  Future<void> cacheMovieDetail(MovieDetail movieDetail) async {
    try {
      await detailsBox.put(movieDetail.id, {
        'cachedAt': DateTime.now().toUtc().toIso8601String(),
        'data': movieDetail.toJson(),
      });
    } catch (e) {
      throw CacheException(
        'Impossible de mettre en cache le film #${movieDetail.id} : $e',
      );
    }
  }

  @override
  Future<MovieDetail?> getCachedMovieDetail(int movieId) async {
    try {
      final rawValue = detailsBox.get(movieId);
      if (rawValue == null) return null;
      if (rawValue is! Map) return null;

      final rawMap = Map<String, dynamic>.from(rawValue as Map);
      final cachedAt = DateTime.tryParse(rawMap['cachedAt'] as String? ?? '');
      if (cachedAt == null ||
          DateTime.now().toUtc().difference(cachedAt) > cacheTtl) {
        return null;
      }
      final map = Map<String, dynamic>.from(rawMap['data'] as Map);
      return MovieDetail.fromCacheJson(map);
    } catch (e) {
      throw CacheException(
        'Erreur de lecture du cache pour le film #$movieId : $e',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    await trendingBox.clear();
    await detailsBox.clear();
  }
}
