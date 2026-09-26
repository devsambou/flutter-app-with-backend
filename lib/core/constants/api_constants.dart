class ApiConstants {
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseW500 = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbImageBaseOriginal =
      'https://image.tmdb.org/t/p/original';

  static const String trendingMovies = '/trending/movie/day';
  static const String popularMovies = '/movie/popular';
  static const String searchMovie = '/search/movie';

  static String movieDetail(int id) => '/movie/$id';
  static String movieCredits(int id) => '/movie/$id/credits';
  static String movieVideos(int id) => '/movie/$id/videos';
}
