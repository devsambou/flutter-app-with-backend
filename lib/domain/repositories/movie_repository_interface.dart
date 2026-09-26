import '../models/movie.dart';
import '../models/movie_detail.dart';

abstract class MovieRepositoryInterface {
  /// Récupère les films du moment (cache-first avec fallback si hors-ligne)
  Future<List<Movie>> getTrendingMovies({
    int page = 1,
    bool forceRefresh = false,
  });

  /// Récupère les détails complets d'un film (synopsis, cast, trailer)
  Future<MovieDetail> getMovieDetails(int movieId, {bool forceRefresh = false});

  /// Recherche des films par mot-clé
  Future<List<Movie>> searchMovies(String query, {int page = 1});
}
