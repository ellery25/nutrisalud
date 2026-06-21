/// Domain models for meal discovery (TheMealDB).
library;

class MealIngredient {
  const MealIngredient({required this.name, required this.measure});

  final String name;
  final String measure;

  Map<String, dynamic> toJson() => {'name': name, 'measure': measure};

  factory MealIngredient.fromJson(Map<String, dynamic> json) =>
      MealIngredient(
        name: json['name'] as String? ?? '',
        measure: json['measure'] as String? ?? '',
      );
}

/// Compact representation used in lists/grids (filter endpoints return
/// only id, name and thumbnail).
class MealSummary {
  const MealSummary({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    this.category,
    this.area,
  });

  final String id;
  final String name;
  final String thumbnailUrl;
  final String? category;
  final String? area;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'thumbnailUrl': thumbnailUrl,
        'category': category,
        'area': area,
      };

  factory MealSummary.fromJson(Map<String, dynamic> json) => MealSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
        category: json['category'] as String?,
        area: json['area'] as String?,
      );

  factory MealSummary.fromMealDb(Map<String, dynamic> json) => MealSummary(
        id: json['idMeal'] as String,
        name: json['strMeal'] as String,
        thumbnailUrl: json['strMealThumb'] as String? ?? '',
        category: json['strCategory'] as String?,
        area: json['strArea'] as String?,
      );
}

/// Full recipe.
class Meal {
  const Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnailUrl,
    required this.ingredients,
    this.youtubeUrl,
    this.sourceUrl,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnailUrl;
  final List<MealIngredient> ingredients;
  final String? youtubeUrl;
  final String? sourceUrl;
  final List<String> tags;

  MealSummary get summary => MealSummary(
        id: id,
        name: name,
        thumbnailUrl: thumbnailUrl,
        category: category,
        area: area,
      );

  /// Instruction text split into displayable steps.
  List<String> get instructionSteps => instructions
      .split(RegExp(r'(\r?\n)+'))
      .map((s) => s.trim().replaceFirst(RegExp(r'^(STEP\s*)?\d+[).:]?\s*'), ''))
      .where((s) => s.isNotEmpty)
      .toList();

  factory Meal.fromMealDb(Map<String, dynamic> json) {
    final ingredients = <MealIngredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = (json['strIngredient$i'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;
      final measure = (json['strMeasure$i'] as String?)?.trim() ?? '';
      ingredients.add(MealIngredient(name: name, measure: measure));
    }
    final youtube = (json['strYoutube'] as String?)?.trim();
    final source = (json['strSource'] as String?)?.trim();
    final tags = (json['strTags'] as String?)
            ?.split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList() ??
        const <String>[];

    return Meal(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String? ?? 'Unknown',
      category: json['strCategory'] as String? ?? 'Other',
      area: json['strArea'] as String? ?? 'International',
      instructions: json['strInstructions'] as String? ?? '',
      thumbnailUrl: json['strMealThumb'] as String? ?? '',
      ingredients: ingredients,
      youtubeUrl: (youtube?.isEmpty ?? true) ? null : youtube,
      sourceUrl: (source?.isEmpty ?? true) ? null : source,
      tags: tags,
    );
  }
}

class MealCategory {
  const MealCategory({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.description,
  });

  final String id;
  final String name;
  final String thumbnailUrl;
  final String description;

  factory MealCategory.fromMealDb(Map<String, dynamic> json) => MealCategory(
        id: json['idCategory'] as String,
        name: json['strCategory'] as String,
        thumbnailUrl: json['strCategoryThumb'] as String? ?? '',
        description: json['strCategoryDescription'] as String? ?? '',
      );
}
