class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String trending = '/';
  static const String search = '/search';
  static const String movieDetail = '/movie/:id';

  static String movieDetailPath(int movieId) => '/movie/$movieId';
}
