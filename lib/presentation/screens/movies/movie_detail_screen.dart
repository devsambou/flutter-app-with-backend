import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../providers/movie_providers.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  Future<void> _openTrailer(BuildContext context, String trailerKey) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=$trailerKey');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir la bande-annonce'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(movieDetailProvider(movieId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: AsyncValueWidget(
              value: detailAsync,
              onRetry: () => ref.refresh(movieDetailProvider(movieId)),
              data: (movie) {
                final backdropUrl = movie.fullBackdropUrl;
                final posterUrl = movie.fullPosterUrl;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // En-tête SliverAppBar avec Backdrop et dégradé
                    SliverAppBar(
                      expandedHeight: 280,
                      pinned: true,
                      backgroundColor: AppColors.background,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (backdropUrl != null)
                              CachedNetworkImage(
                                imageUrl: backdropUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: AppColors.surfaceVariant),
                                errorWidget: (context, url, error) =>
                                    Container(color: AppColors.surfaceVariant),
                              )
                            else
                              Container(color: AppColors.surfaceVariant),

                            // Dégradé sombre pour lisibilité du titre
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.3),
                                    Colors.transparent,
                                    AppColors.background.withValues(alpha: 0.9),
                                    AppColors.background,
                                  ],
                                  stops: const [0.0, 0.4, 0.8, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Contenu principal des détails
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ligne Titre + Poster miniature
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (posterUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: posterUrl,
                                      width: 100,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (movie.tagline != null &&
                                          movie.tagline!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          '« ${movie.tagline!} »',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontStyle: FontStyle.italic,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      // Score et Durée
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 8,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceVariant,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  color: AppColors.primary,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${movie.voteAverage.toStringAsFixed(1)} / 10',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceVariant,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.access_time_rounded,
                                                  color:
                                                      AppColors.textSecondary,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  movie.formattedRuntime,
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Genres
                            if (movie.genres.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: movie.genres.map((genre) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.textMuted.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      genre,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Bouton Bande-Annonce
                            if (movie.trailerKey != null) ...[
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () =>
                                      _openTrailer(context, movie.trailerKey!),
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 24,
                                  ),
                                  label: const Text(
                                    'Regarder la bande-annonce (YouTube)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Synopsis
                            const Text(
                              'Synopsis',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              movie.overview.isNotEmpty
                                  ? movie.overview
                                  : 'Aucun synopsis disponible pour ce titre.',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Casting
                            if (movie.cast.isNotEmpty) ...[
                              const Text(
                                'Distribution principale',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 140,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: movie.cast.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 14),
                                  itemBuilder: (context, index) {
                                    final actor = movie.cast[index];
                                    final photoUrl = actor.fullProfileUrl;

                                    return SizedBox(
                                      width: 85,
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 34,
                                            backgroundColor:
                                                AppColors.surfaceVariant,
                                            backgroundImage: photoUrl != null
                                                ? CachedNetworkImageProvider(
                                                    photoUrl,
                                                  )
                                                : null,
                                            child: photoUrl == null
                                                ? const Icon(
                                                    Icons.person_rounded,
                                                    color: AppColors.textMuted,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            actor.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            actor.character,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
