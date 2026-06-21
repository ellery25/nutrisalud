import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/key_value_store.dart';
import '../domain/meal.dart';

/// Favorite meals, persisted locally as meal summaries so the favorites
/// screen renders instantly and offline.
final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<MealSummary>>(
  FavoritesNotifier.new,
);

final isFavoriteProvider = Provider.family<bool, String>((ref, mealId) =>
    ref.watch(favoritesProvider).any((m) => m.id == mealId));

class FavoritesNotifier extends Notifier<List<MealSummary>> {
  KeyValueStore get _kv => ref.read(keyValueStoreProvider);

  @override
  List<MealSummary> build() {
    final raw = _kv.getStringList(StorageKeys.favoriteMealIds) ?? const [];
    final favorites = <MealSummary>[];
    for (final item in raw) {
      try {
        favorites.add(
          MealSummary.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } on FormatException {
        // Skip corrupt entries instead of failing the whole list.
      }
    }
    return favorites;
  }

  Future<void> toggle(MealSummary meal) async {
    final exists = state.any((m) => m.id == meal.id);
    state = exists
        ? state.where((m) => m.id != meal.id).toList()
        : [...state, meal];
    await _kv.setStringList(
      StorageKeys.favoriteMealIds,
      state.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }
}
