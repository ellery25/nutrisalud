import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../domain/meal.dart';

final mealDbApiProvider = Provider<MealDbApi>(
  (ref) => MealDbApi(ref.watch(apiClientProvider)),
);

/// TheMealDB client — free public recipe API.
/// https://www.themealdb.com/api.php
class MealDbApi {
  MealDbApi(this._client);

  final ApiClient _client;

  Uri _uri(String pathAndQuery) =>
      Uri.parse('${AppConstants.mealDbApiBase}/$pathAndQuery');

  /// Full-text search. Empty query returns a default selection.
  Future<List<Meal>> search(String query) async {
    final data = await _client
        .getJson(_uri('search.php?s=${Uri.encodeQueryComponent(query)}'));
    return _mealsFrom(data);
  }

  Future<Meal?> lookup(String id) async {
    final data =
        await _client.getJson(_uri('lookup.php?i=${Uri.encodeComponent(id)}'));
    final meals = _mealsFrom(data);
    return meals.isEmpty ? null : meals.first;
  }

  Future<List<MealCategory>> categories() async {
    final data = await _client.getJson(_uri('categories.php'));
    final list = (data as Map<String, dynamic>)['categories'] as List? ?? [];
    return list
        .cast<Map<String, dynamic>>()
        .map(MealCategory.fromMealDb)
        .toList();
  }

  Future<List<MealSummary>> filterByCategory(String category) =>
      _filter('filter.php?c=${Uri.encodeQueryComponent(category)}');

  Future<List<MealSummary>> filterByIngredient(String ingredient) =>
      _filter('filter.php?i=${Uri.encodeQueryComponent(ingredient)}');

  /// One random meal (used to build daily suggestions).
  Future<Meal?> random() async {
    final data = await _client.getJson(_uri('random.php'));
    final meals = _mealsFrom(data);
    return meals.isEmpty ? null : meals.first;
  }

  Future<List<MealSummary>> _filter(String pathAndQuery) async {
    final data = await _client.getJson(_uri(pathAndQuery));
    final list = (data as Map<String, dynamic>)['meals'] as List? ?? [];
    return list
        .cast<Map<String, dynamic>>()
        .map(MealSummary.fromMealDb)
        .toList();
  }

  List<Meal> _mealsFrom(dynamic data) {
    final list = (data as Map<String, dynamic>)['meals'] as List? ?? [];
    return list.cast<Map<String, dynamic>>().map(Meal.fromMealDb).toList();
  }
}
