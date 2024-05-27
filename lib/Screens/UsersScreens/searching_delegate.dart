import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nutrisalud/Helpers/colors_codes.dart';
import 'package:nutrisalud/Screens/screens_export.dart';
import 'dart:convert';
import 'package:nutrisalud/Widgets/SearchWidgets/recipe_preview.dart';

class SearchRecipes extends SearchDelegate {
  Future<List<Map<String, dynamic>>> searchRecipes(String query) async {
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/search.php?s=$query'));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List<Map<String, dynamic>> recipes = [];
      for (var item in jsonResponse['meals']) {
        recipes.add(item);
      }
      return recipes;
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: searchRecipes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: ColorsConstants.darkGreen,
          ));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              return RecipePreview(
                idmeal: snapshot.data?[index]['idMeal'],
                nameRecipe: snapshot.data?[index]['strMeal'],
                imageRecipe: snapshot.data?[index]['strMealThumb'],
                category: snapshot.data?[index]['strCategory'],
                area: snapshot.data?[index]['strArea'],
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecipeDetails(
                              idmeal: snapshot.data?[index]['idMeal'],
                              nameRecipe: snapshot.data?[index]['strMeal'],
                              imageRecipe: snapshot.data?[index]['strMealThumb'],
                              category: snapshot.data?[index]['strCategory'],
                              area: snapshot.data?[index]['strArea'],
                              instructions: snapshot.data?[index]['strInstructions'],
                              ingredient1: snapshot.data?[index]['strIngredient1'],
                              ingredient2: snapshot.data?[index]
                                    ['strIngredient2'],
                              ingredient3: snapshot.data?[index]
                                    ['strIngredient3'],
                              ingredient4: snapshot.data?[index]
                                    ['strIngredient4'],
                              ingredient5: snapshot.data?[index]
                                    ['strIngredient5'],
                              ingredient6: snapshot.data?[index]
                                    ['strIngredient6'],
                              ingredient7: snapshot.data?[index]
                                    ['strIngredient7'],
                              ingredient8: snapshot.data?[index]
                                    ['strIngredient8'],
                              ingredient9: snapshot.data?[index]
                                    ['strIngredient9'],
                              ingredient10: snapshot.data?[index]
                                    ['strIngredient10'],
                              ingredient11: snapshot.data?[index]
                                    ['strIngredient11'],
                              ingredient12: snapshot.data?[index]
                                    ['strIngredient12'],
                              ingredient13: snapshot.data?[index]
                                    ['strIngredient13'],
                              ingredient14: snapshot.data?[index]
                                    ['strIngredient14'],
                              ingredient15: snapshot.data?[index]
                                    ['strIngredient15'],
                              ingredient16: snapshot.data?[index]
                                    ['strIngredient16'],
                              ingredient17: snapshot.data?[index]
                                    ['strIngredient17'],
                              ingredient18: snapshot.data?[index]
                                    ['strIngredient18'],
                              ingredient19: snapshot.data?[index]
                                    ['strIngredient19'],
                              ingredient20: snapshot.data?[index]
                                    ['strIngredient20'],
                              measure1: snapshot.data?[index]['strMeasure1'],
                              measure2: snapshot.data?[index]['strMeasure2'],
                              measure3: snapshot.data?[index]['strMeasure3'],
                              measure4: snapshot.data?[index]['strMeasure4'],
                              measure5: snapshot.data?[index]['strMeasure5'],
                              measure6: snapshot.data?[index]['strMeasure6'],
                              measure7: snapshot.data?[index]['strMeasure7'],
                              measure8: snapshot.data?[index]['strMeasure8'],
                              measure9: snapshot.data?[index]['strMeasure9'],
                              measure10: snapshot.data?[index]['strMeasure10'],
                              measure11: snapshot.data?[index]['strMeasure11'],
                              measure12: snapshot.data?[index]['strMeasure12'],
                              measure13: snapshot.data?[index]['strMeasure13'],
                              measure14: snapshot.data?[index]['strMeasure14'],
                              measure15: snapshot.data?[index]['strMeasure15'],
                              measure16: snapshot.data?[index]['strMeasure16'],
                              measure17: snapshot.data?[index]['strMeasure17'],
                              measure18: snapshot.data?[index]['strMeasure18'],
                              measure19: snapshot.data?[index]['strMeasure19'],
                              measure20: snapshot.data?[index]['strMeasure20'],
                              youtube: snapshot.data?[index]['strYoutube'],)));
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: searchRecipes(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return RecipePreview(
                idmeal: snapshot.data?[index]['idMeal'],
                nameRecipe: snapshot.data?[index]['strMeal'],
                imageRecipe: snapshot.data?[index]['strMealThumb'],
                category: snapshot.data?[index]['strCategory'],
                area: snapshot.data?[index]['strArea'],
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecipeDetails(
                                idmeal: snapshot.data?[index]['idMeal'],
                                nameRecipe: snapshot.data?[index]['strMeal'],
                                imageRecipe: snapshot.data?[index]
                                    ['strMealThumb'],
                                category: snapshot.data?[index]['strCategory'],
                                area: snapshot.data?[index]['strArea'],
                                instructions: snapshot.data?[index]
                                    ['strInstructions'],
                                ingredient1: snapshot.data?[index]
                                    ['strIngredient1'],
                                ingredient2: snapshot.data?[index]
                                    ['strIngredient2'],
                                ingredient3: snapshot.data?[index]
                                    ['strIngredient3'],
                                ingredient4: snapshot.data?[index]
                                    ['strIngredient4'],
                                ingredient5: snapshot.data?[index]
                                    ['strIngredient5'],
                                ingredient6: snapshot.data?[index]
                                    ['strIngredient6'],
                                ingredient7: snapshot.data?[index]
                                    ['strIngredient7'],
                                ingredient8: snapshot.data?[index]
                                    ['strIngredient8'],
                                ingredient9: snapshot.data?[index]
                                    ['strIngredient9'],
                                ingredient10: snapshot.data?[index]
                                    ['strIngredient10'],
                                ingredient11: snapshot.data?[index]
                                    ['strIngredient11'],
                                ingredient12: snapshot.data?[index]
                                    ['strIngredient12'],
                                ingredient13: snapshot.data?[index]
                                    ['strIngredient13'],
                                ingredient14: snapshot.data?[index]
                                    ['strIngredient14'],
                                ingredient15: snapshot.data?[index]
                                    ['strIngredient15'],
                                ingredient16: snapshot.data?[index]
                                    ['strIngredient16'],
                                ingredient17: snapshot.data?[index]
                                    ['strIngredient17'],
                                ingredient18: snapshot.data?[index]
                                    ['strIngredient18'],
                                ingredient19: snapshot.data?[index]
                                    ['strIngredient19'],
                                ingredient20: snapshot.data?[index]
                                    ['strIngredient20'],
                                measure1: snapshot.data?[index]['strMeasure1'],
                                measure2: snapshot.data?[index]['strMeasure2'],
                                measure3: snapshot.data?[index]['strMeasure3'],
                                measure4: snapshot.data?[index]['strMeasure4'],
                                measure5: snapshot.data?[index]['strMeasure5'],
                                measure6: snapshot.data?[index]['strMeasure6'],
                                measure7: snapshot.data?[index]['strMeasure7'],
                                measure8: snapshot.data?[index]['strMeasure8'],
                                measure9: snapshot.data?[index]['strMeasure9'],
                                measure10: snapshot.data?[index]
                                    ['strMeasure10'],
                                measure11: snapshot.data?[index]
                                    ['strMeasure11'],
                                measure12: snapshot.data?[index]
                                    ['strMeasure12'],
                                measure13: snapshot.data?[index]
                                    ['strMeasure13'],
                                measure14: snapshot.data?[index]
                                    ['strMeasure14'],
                                measure15: snapshot.data?[index]
                                    ['strMeasure15'],
                                measure16: snapshot.data?[index]
                                    ['strMeasure16'],
                                measure17: snapshot.data?[index]
                                    ['strMeasure17'],
                                measure18: snapshot.data?[index]
                                    ['strMeasure18'],
                                measure19: snapshot.data?[index]
                                    ['strMeasure19'],
                                measure20: snapshot.data?[index]
                                    ['strMeasure20'],
                                youtube: snapshot.data?[index]['strYoutube'],
                              )));
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const Center(
            child: CircularProgressIndicator(
          color: ColorsConstants.darkGreen,
        ));
      },
    );
  }
}
