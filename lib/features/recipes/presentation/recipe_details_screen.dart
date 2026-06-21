import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/remote_image.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../../meals/data/favorites_repository.dart';
import '../../meals/data/mealdb_api.dart';
import '../../meals/domain/meal.dart';
import '../../meals/presentation/widgets/meal_card.dart';

final _mealProvider = FutureProvider.autoDispose.family<Meal?, String>(
  (ref, id) => ref.watch(mealDbApiProvider).lookup(id),
);

final _relatedProvider =
    FutureProvider.autoDispose.family<List<MealSummary>, String>(
  (ref, category) => ref.watch(mealDbApiProvider).filterByCategory(category),
);

/// Full recipe view: hero image, ingredients, steps and related meals.
class RecipeDetailsScreen extends ConsumerWidget {
  const RecipeDetailsScreen({super.key, required this.mealId});

  final String mealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealValue = ref.watch(_mealProvider(mealId));

    return Scaffold(
      body: mealValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SafeArea(
          child: Column(
            children: [
              Align(alignment: Alignment.topLeft, child: BackButton()),
              Expanded(
                child: ErrorState(
                  message: error.toString().replaceFirst('Exception: ', ''),
                  onRetry: () => ref.invalidate(_mealProvider(mealId)),
                ),
              ),
            ],
          ),
        ),
        data: (meal) {
          if (meal == null) {
            return const SafeArea(
              child: Column(
                children: [
                  Align(alignment: Alignment.topLeft, child: BackButton()),
                  Expanded(
                    child: EmptyState(
                      icon: Icons.no_meals,
                      title: 'Recipe not found',
                      message: 'This recipe is no longer available.',
                    ),
                  ),
                ],
              ),
            );
          }
          return _RecipeBody(meal: meal);
        },
      ),
    );
  }
}

class _RecipeBody extends ConsumerWidget {
  const _RecipeBody({required this.meal});

  final Meal meal;

  Future<void> _openUrl(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(isFavoriteProvider(meal.id));
    final steps = meal.instructionSteps;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          actions: [
            IconButton(
              tooltip:
                  isFavorite ? 'Remove from favorites' : 'Add to favorites',
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).toggle(meal.summary),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsetsDirectional.only(
              start: AppSpacing.md,
              bottom: AppSpacing.md,
              end: AppSpacing.xxl,
            ),
            title: Text(
              meal.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                RemoteImage(url: meal.thumbnailUrl),
                // Scrim keeps the title legible over any photo.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                      stops: [0.45, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverList.list(
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  Chip(
                    avatar: const Icon(Icons.category_outlined, size: 18),
                    label: Text(meal.category),
                  ),
                  Chip(
                    avatar: const Icon(Icons.public, size: 18),
                    label: Text(meal.area),
                  ),
                  for (final tag in meal.tags) Chip(label: Text(tag)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const SectionHeader(title: 'Ingredients'),
              ...meal.ingredients.map(
                (ingredient) => _IngredientRow(ingredient: ingredient),
              ),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Instructions'),
              for (var i = 0; i < steps.length; i++)
                _StepRow(index: i, text: steps[i]),
              if (meal.youtubeUrl != null) ...[
                const SizedBox(height: AppSpacing.md),
                const SectionHeader(title: "Watch how it's made"),
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.play_circle,
                      size: 36,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Watch video tutorial on YouTube'),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => _openUrl(meal.youtubeUrl!),
                  ),
                ),
              ],
              if (meal.sourceUrl != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _openUrl(meal.sourceUrl!),
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('View original source'),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              SectionHeader(title: 'More ${meal.category} recipes'),
              _RelatedMeals(category: meal.category, excludeId: meal.id),
            ],
          ),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient});

  final MealIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: AppSpacing.sm),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: ingredient.name,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
                children: [
                  if (ingredient.measure.isNotEmpty)
                    TextSpan(
                      text: ' — ${ingredient.measure}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              '${index + 1}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _RelatedMeals extends ConsumerWidget {
  const _RelatedMeals({required this.category, required this.excludeId});

  final String category;
  final String excludeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedValue = ref.watch(_relatedProvider(category));
    return relatedValue.maybeWhen(
      data: (meals) {
        final related =
            meals.where((m) => m.id != excludeId).take(8).toList();
        if (related.isEmpty) {
          return Text(
            'No related recipes found.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          );
        }
        return SizedBox(
          height: 252,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) =>
                MealCard(meal: related[index], width: 180),
          ),
        );
      },
      // Related content is supplementary: keep failures quiet.
      orElse: () => const SizedBox(
        height: 252,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
