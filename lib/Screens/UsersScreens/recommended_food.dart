import 'package:flutter/material.dart';
import 'package:nutrisalud/Providers/meals_providers.dart';
import 'package:nutrisalud/Widgets/RecommendedFoodWidgets/food_recomendation.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';

class RecommendedFood extends StatefulWidget {
  const RecommendedFood({super.key});
  @override
  State<RecommendedFood> createState() => _RecommendedFoodState();
}

class _RecommendedFoodState extends State<RecommendedFood> {
  bool isLoading = true;
  List<Widget> foodPostsList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsConstants.whiteColor,
      appBar: AppBar(
        title: const Text('Food Recommendation'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<Meal>>(
            future: Meal.getMeals(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: ColorsConstants.darkGreen),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<Meal>? meals = snapshot.data;
                if (meals == null || meals.isEmpty) {
                  return const Center(child: Text('No meals found'));
                } else {
                  return ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      return FoodRecomendation(
                        titulo: meals[index].strMeal,
                        timeToEat:
                            'Anytime', // Puedes ajustar esto según tus necesidades
                        descripcion:
                            '${meals[index].strInstructions.substring(0, 50)}...',
                        meal: meals[index],
                      );
                    },
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
