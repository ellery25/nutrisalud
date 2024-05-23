import 'package:flutter/material.dart';
import 'package:nutrisalud/Providers/meals_providers.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/general_blocks.dart';
import 'package:nutrisalud/Widgets/RecommendedFoodWidgets/food_recomendation.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:nutrisalud/Preferences/save_load.dart';

class RecommendedFood extends StatefulWidget {
  const RecommendedFood({super.key});
  @override
  State<RecommendedFood> createState() => _RecommendedFoodState();
}

class _RecommendedFoodState extends State<RecommendedFood> {
  bool isLoading = true;
  List<Widget> foodPostsList = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> llenarCommunityPostsList() async {
    print('Llenando la lista de community posts');

    final List<Meal>? recetas = await Meal.getMeals();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Food Recommendation'),
        ),
        body: FutureBuilder<List<Meal>>(
          future: Meal.getMeals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Meal>? meals = snapshot.data;
              if (meals == null || meals.isEmpty) {
                return Center(child: Text('No meals found'));
              } else {
                return ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    return FoodRecomendation(
                      titulo: meals[index].strMeal,
                      timeToEat:
                          'Anytime', // Puedes ajustar esto según tus necesidades
                      descripcion:
                          meals[index].strInstructions.substring(0, 50) + '...',
                      meal: meals[index],
                    );
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }
}
