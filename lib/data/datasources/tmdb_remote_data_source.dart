import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/tmdb_dio_client.dart';
import '../../domain/models/movie.dart';
import '../../domain/models/movie_detail.dart';

abstract class TmdbRemoteDataSource {
  Future<List<Movie>> fetchTrendingMovies({int page = 1});
  Future<MovieDetail> fetchMovieDetails(int movieId);
  Future<List<Movie>> searchMovies(String query, {int page = 1});
}

class TmdbRemoteDataSourceImpl implements TmdbRemoteDataSource {
  final TmdbDioClient client;

  TmdbRemoteDataSourceImpl(this.client);

  @override
  Future<List<Movie>> fetchTrendingMovies({int page = 1}) async {
    try {
      final response = await client.dio.get(
        ApiConstants.trendingMovies,
        queryParameters: {'page': page},
      );

      final results = response.data['results'] as List<dynamic>? ?? [];
      return results
          .map((item) => Movie.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(
        e.message ?? 'Erreur lors de la récupération des films du moment',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException('Erreur inattendue : $e');
    }
  }

  @override
  Future<MovieDetail> fetchMovieDetails(int movieId) async {
    try {
      // Appels parallèles pour les détails, les crédits et les vidéos
      final detailFuture = client.dio.get(ApiConstants.movieDetail(movieId));
      final creditsFuture = client.dio.get(ApiConstants.movieCredits(movieId));
      final videosFuture = client.dio.get(ApiConstants.movieVideos(movieId));

      final results = await Future.wait([
        detailFuture,
        creditsFuture,
        videosFuture,
      ]);

      final detailData = results[0].data as Map<String, dynamic>;
      final creditsData = results[1].data as Map<String, dynamic>;
      final videosData = results[2].data as Map<String, dynamic>;

      // Extraction du cast (top 10 acteurs)
      final rawCast = creditsData['cast'] as List<dynamic>? ?? [];
      final castMembers = rawCast
          .take(10)
          .map((c) => CastMember.fromJson(c as Map<String, dynamic>))
          .toList();

      // Extraction du trailer officiel YouTube
      final rawVideos = videosData['results'] as List<dynamic>? ?? [];
      String? trailerKey;
      for (final video in rawVideos) {
        final site = video['site'] as String?;
        final type = video['type'] as String?;
        if (site == 'YouTube' && (type == 'Trailer' || type == 'Teaser')) {
          trailerKey = video['key'] as String?;
          break;
        }
      }

      return MovieDetail.fromJson(
        detailData,
        cast: castMembers,
        trailerKey: trailerKey,
      );
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(
        e.message ?? 'Impossible de récupérer les détails du film #$movieId',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException('Erreur lors du chargement des détails : $e');
    }
  }

  @override
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await client.dio.get(
        ApiConstants.searchMovie,
        queryParameters: {'query': query, 'page': page},
      );

      final results = response.data['results'] as List<dynamic>? ?? [];
      return results
          .map((item) => Movie.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(
        e.message ?? 'Erreur lors de la recherche de films',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException('Erreur inattendue de recherche : $e');
    }
  }
}
