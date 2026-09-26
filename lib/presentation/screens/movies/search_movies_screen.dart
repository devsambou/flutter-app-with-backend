import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../routing/app_routes.dart';
import '../../providers/movie_providers.dart';
import '../../widgets/movie_card.dart';

class SearchMoviesScreen extends ConsumerStatefulWidget {
  const SearchMoviesScreen({super.key});

  @override
  ConsumerState<SearchMoviesScreen> createState() => _SearchMoviesScreenState();
}

class _SearchMoviesScreenState extends ConsumerState<SearchMoviesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchMoviesProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Rechercher',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              style: const TextStyle(color: AppColors.textPrimary),
              onSubmitted: _onSearch,
              onChanged: (val) {
                // Recherche instantanée si plus de 2 caractères
                if (val.length >= 2 || val.isEmpty) {
                  _onSearch(val);
                }
              },
              decoration: InputDecoration(
                hintText: 'Titre de film (ex: Inception, Avatar...)',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Résultats de recherche
          Expanded(
            child: query.trim().isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: AppColors.surfaceVariant,
                          size: 72,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Trouvez un film parmi le catalogue TMDB',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : AsyncValueWidget(
                    value: searchAsync,
                    onRetry: () => ref.refresh(searchMoviesProvider),
                    data: (movies) {
                      if (movies.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.sentiment_dissatisfied_rounded,
                                color: AppColors.textMuted,
                                size: 54,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Aucun résultat trouvé pour « $query »',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
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
                              context.push(AppRoutes.movieDetailPath(movie.id));
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
