import 'dart:convert';
import 'package:http/http.dart' as http;

class Meal {
  final String idMeal;
  final String strMeal;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String? strImageSource;
  final String strYoutube;
  final List<Ingredients> strIngredients;

  Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strYoutube,
    required this.strIngredients,
    this.strImageSource,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      idMeal: json['idMeal'],
      strMeal: json['strMeal'],
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
      strYoutube: json['strYoutube'],
      strIngredients: List.generate(
        20,
        (index) {
          String? ingredient = json['strIngredient${index + 1}'];
          String? measure = json['strMeasure${index + 1}'];
          if (ingredient != null && ingredient.isNotEmpty) {
            return Ingredients(ingredient, measure ?? '');
          }
          return null;
        },
      ).whereType<Ingredients>().toList(),
      strImageSource: json['strImageSource'],
    );
  }

  static Future<List<Meal>> getMeals() async {
    String url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=';
    Uri uri = Uri.parse(url);
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      print(response.body);
      List<dynamic> jsonList = jsonDecode(response.body)['meals'];

      return jsonList.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }
}

class Ingredients {
  final String name;
  final String measure;
  Ingredients(this.name, this.measure);
}
