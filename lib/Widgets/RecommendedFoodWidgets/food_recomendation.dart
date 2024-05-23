import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:nutrisalud/Providers/meals_providers.dart';

class FoodRecomendation extends StatelessWidget {
  final String titulo;
  final String timeToEat;
  final String descripcion;
  final Meal meal;

  const FoodRecomendation({
    super.key,
    required this.titulo,
    required this.timeToEat,
    required this.descripcion,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
          border: Border.all(color: ColorsConstants.darkGreen),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: ColorsConstants.darkGreen,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    'Best time to eat: $timeToEat',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: ColorsConstants.darkGreen,
                    ),
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: ColorsConstants.darkGreen,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingredients:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: ColorsConstants.darkGreen,
                  ),
                ),
                ...meal.strIngredients.map((ingredient) => Text(
                      '- ${ingredient.name}: ${ingredient.measure}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: ColorsConstants.darkGreen,
                      ),
                    )),
                const SizedBox(height: 10),
                const Text(
                  'Instructions:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: ColorsConstants.darkGreen,
                  ),
                ),
                Text(
                  meal.strInstructions,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: ColorsConstants.darkGreen,
                  ),
                ),
                const SizedBox(height: 10),
                if (meal.strImageSource != null)
                  Image.network(meal.strImageSource!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
