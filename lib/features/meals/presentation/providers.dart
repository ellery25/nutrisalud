import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mealdb_api.dart';
import '../domain/meal.dart';

enum SearchMode { name, ingredient }

final searchModeProvider = StateProvider<SearchMode>((ref) => SearchMode.name);

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    FutureProvider.autoDispose<List<MealSummary>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  final mode = ref.watch(searchModeProvider);
  if (query.isEmpty) return const [];
  final api = ref.watch(mealDbApiProvider);
  return switch (mode) {
    SearchMode.name =>
      (await api.search(query)).map((m) => m.summary).toList(),
    SearchMode.ingredient => api.filterByIngredient(query),
  };
});

final categoriesProvider = FutureProvider<List<MealCategory>>(
  (ref) => ref.watch(mealDbApiProvider).categories(),
);

final categoryMealsProvider =
    FutureProvider.autoDispose.family<List<MealSummary>, String>(
  (ref, name) => ref.watch(mealDbApiProvider).filterByCategory(name),
);

/// TheMealDB returns a default selection for an empty search query.
final featuredMealsProvider = FutureProvider<List<MealSummary>>((ref) async {
  final meals = await ref.watch(mealDbApiProvider).search('');
  return meals.map((m) => m.summary).toList();
});
