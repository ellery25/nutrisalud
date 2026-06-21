import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../shared/widgets/remote_image.dart';
import '../../data/favorites_repository.dart';
import '../../domain/meal.dart';

/// Grid/list card for a meal with image, name and a favorite toggle.
class MealCard extends ConsumerWidget {
  const MealCard({super.key, required this.meal, this.width});

  final MealSummary meal;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(isFavoriteProvider(meal.id));
    final caption = [
      meal.category,
      meal.area,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');

    final card = Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => context.push(RoutePaths.recipeFor(meal.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: RemoteImage(url: meal.thumbnailUrl),
                ),
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: _FavoriteButton(
                    isFavorite: isFavorite,
                    onPressed: () =>
                        ref.read(favoritesProvider.notifier).toggle(meal),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + AppSpacing.xs,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        meal.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (caption.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (width == null) return card;
    return SizedBox(width: width, child: card);
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Dark scrim keeps the white icon readable over any photo.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
