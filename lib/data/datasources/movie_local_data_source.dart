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

  final Box trendingBox;
  final Box detailsBox;

  MovieLocalDataSourceImpl({
    required this.trendingBox,
    required this.detailsBox,
  });

  @override
  Future<void> cacheTrendingMovies(List<Movie> movies, {int page = 1}) async {
    try {
      final jsonList = movies.map((m) => m.toJson()).toList();
      await trendingBox.put('trending_page_$page', jsonList);
    } catch (e) {
      throw CacheException(
        'Impossible de mettre en cache les films populaires : $e',
      );
    }
  }

  @override
  Future<List<Movie>> getCachedTrendingMovies({int page = 1}) async {
    try {
      final rawList = trendingBox.get('trending_page_$page');
      if (rawList == null) {
        return [];
      }
      final list = (rawList as List)
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
      await detailsBox.put(movieDetail.id, movieDetail.toJson());
    } catch (e) {
      throw CacheException(
        'Impossible de mettre en cache le film #${movieDetail.id} : $e',
      );
    }
  }

  @override
  Future<MovieDetail?> getCachedMovieDetail(int movieId) async {
    try {
      final rawMap = detailsBox.get(movieId);
      if (rawMap == null) return null;

      final map = Map<String, dynamic>.from(rawMap as Map);
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
