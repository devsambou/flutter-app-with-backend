import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../routing/app_routes.dart';
import '../../providers/auth_providers.dart';
import '../../providers/movie_providers.dart';
import '../../widgets/movie_card.dart';

class TrendingMoviesScreen extends ConsumerWidget {
  const TrendingMoviesScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Déconnexion',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter de votre session Supabase ?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingMoviesAsync = ref.watch(trendingMoviesProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.movie_filter_rounded,
              color: AppColors.primary,
              size: 26,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MovieVault',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Rechercher un film',
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Se déconnecter',
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                return ref.refresh(trendingMoviesProvider.future);
              },
              child: AsyncValueWidget(
                value: trendingMoviesAsync,
                onRetry: () => ref.refresh(trendingMoviesProvider),
                data: (movies) {
                  if (movies.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucun film disponible',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return MovieCard(
                        movie: movie,
                        onTap: () {
                          // Navigation par ID primitif uniquement (règle stricte)
                          context.push(AppRoutes.movieDetailPath(movie.id));
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
