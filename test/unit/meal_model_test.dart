import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisalud/features/meals/domain/meal.dart';

void main() {
  group('Meal.fromMealDb', () {
    test('aggregates the 20 ingredient/measure columns into a list', () {
      final meal = Meal.fromMealDb({
        'idMeal': '52772',
        'strMeal': 'Teriyaki Chicken',
        'strCategory': 'Chicken',
        'strArea': 'Japanese',
        'strInstructions': 'Step one.\r\nStep two.',
        'strMealThumb': 'https://example.com/x.jpg',
        'strYoutube': '',
        'strIngredient1': 'soy sauce',
        'strMeasure1': '3/4 cup',
        'strIngredient2': 'water',
        'strMeasure2': '1/2 cup',
        'strIngredient3': '',
        'strMeasure3': ' ',
        'strIngredient4': null,
      });

      expect(meal.ingredients, hasLength(2));
      expect(meal.ingredients.first.name, 'soy sauce');
      expect(meal.ingredients.first.measure, '3/4 cup');
      expect(meal.youtubeUrl, isNull, reason: 'empty string becomes null');
    });

    test('splits instructions into trimmed steps', () {
      final meal = Meal.fromMealDb({
        'idMeal': '1',
        'strMeal': 'X',
        'strInstructions': '1. Preheat oven.\r\n\r\n2) Mix flour.\nSTEP 3: Bake.',
      });

      expect(meal.instructionSteps,
          ['Preheat oven.', 'Mix flour.', 'Bake.']);
    });

    test('parses tags and survives missing optional fields', () {
      final meal = Meal.fromMealDb({
        'idMeal': '2',
        'strMeal': 'Y',
        'strTags': 'Meat,Casserole, ',
      });

      expect(meal.tags, ['Meat', 'Casserole']);
      expect(meal.category, 'Other');
      expect(meal.ingredients, isEmpty);
    });
  });

  test('MealSummary JSON round-trip', () {
    const summary = MealSummary(
      id: '42',
      name: 'Arepas',
      thumbnailUrl: 'https://example.com/a.jpg',
      category: 'Breakfast',
      area: 'Colombian',
    );
    final restored = MealSummary.fromJson(summary.toJson());
    expect(restored.id, '42');
    expect(restored.name, 'Arepas');
    expect(restored.category, 'Breakfast');
  });
}
