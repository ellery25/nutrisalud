import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/state_views.dart';
import '../data/favorites_repository.dart';
import 'widgets/meal_card.dart';

/// Locally saved favorite meals.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              message: 'Tap the heart on any recipe to save it here.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.72,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) =>
                  MealCard(meal: favorites[index]),
            ),
    );
  }
}
