import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/providers/auth_providers.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/movies/movie_detail_screen.dart';
import '../presentation/screens/movies/search_movies_screen.dart';
import '../presentation/screens/movies/trending_movies_screen.dart';
import 'app_routes.dart';

/// Helper pour rafraîchir GoRouter à chaque émission d'un Stream Dart (Supabase AuthState)
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoutes.trending,
    refreshListenable: GoRouterRefreshStream(authRepo.authStateChanges),
    redirect: (context, state) {
      final isAuthenticated = authRepo.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // 1. Non authentifié : redirection obligatoire vers /login
      if (!isAuthenticated) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      // 2. Authentifié mais sur les pages login/register : redirection vers l'accueil
      if (isAuthRoute) {
        return AppRoutes.trending;
      }

      // 3. Navigation autorisée
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.trending,
        builder: (context, state) => const TrendingMoviesScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchMoviesScreen(),
      ),
      GoRoute(
        path: AppRoutes.movieDetail,
        builder: (context, state) {
          final idParam = state.pathParameters['id'] ?? '0';
          final movieId = int.tryParse(idParam) ?? 0;
          return MovieDetailScreen(movieId: movieId);
        },
      ),
    ],
  );
});
