import 'package:nutrisalud/Widgets/GeneralWidgets/general_blocks.dart';
import 'package:flutter/material.dart';
import 'package:nutrisalud/Widgets/RecommendedFoodWidgets/food_recomendation.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:nutrisalud/Preferences/save_load.dart';

class RecommendedFood extends StatefulWidget {
  const RecommendedFood({super.key});
  @override
  State<RecommendedFood> createState() => _RecommendedFoodState();
}

class _RecommendedFoodState extends State<RecommendedFood> {
  String isNutricionist = "false";

  @override
  void initState() {
    super.initState();
    _cargarIsNutricionist();
  }

  _cargarIsNutricionist() async {
    // Obtener el isNutricionist
    String? isNutricionist =
        await SharedPreferencesHelper.loadData('isNutricionist');
    // Actualizar el estado para reflejar el userId
    setState(() {
      this.isNutricionist = isNutricionist!;
    });

    print('isNutricionist: $isNutricionist');
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Si la variable isNutricionist es false, mostrar el botón flotante
      //floatingActionButton: isNutricionist == true ? FloatingActionButton(onPressed: () {
      // Acciones para añadir un profesional tip
      //},backgroundColor: ColorsConstants.darkGreen,child: const Icon(Icons.add, color: ColorsConstants.whiteColor),): null,
      backgroundColor: ColorsConstants.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              NavBar(
                backButton: false,
                title: "Recommended food",
                backRoute: () {
                  print("Back Recommended food");
                  Navigator.popAndPushNamed(context, AppRoutes.home);
                },
              ),
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FoodRecomendation(
                          titulo: "Banana",
                          timeToEat: "Morning",
                          descripcion:
                              "High in potassium and magnesium, bananas can help your body recover from a night of rest and kickstart your day."),
                      FoodRecomendation(
                          titulo: "Oatmeal",
                          timeToEat: "Breakfast",
                          descripcion:
                              "Rich in fiber and complex carbohydrates, oatmeal provides sustained energy throughout the morning and helps maintain healthy cholesterol levels."),
                      FoodRecomendation(
                          titulo: "Salmon",
                          timeToEat: "Lunch",
                          descripcion:
                              "Packed with omega-3 fatty acids, salmon supports heart health and brain function. It's also a great source of protein for muscle repair and growth."),
                      FoodRecomendation(
                          titulo: "Spinach",
                          timeToEat: "Dinner",
                          descripcion:
                              "Loaded with vitamins A, C, and K, as well as iron and calcium, spinach promotes strong bones and a robust immune system. It's a versatile ingredient that can be incorporated into salads, pastas, and stir-fries."),
                      FoodRecomendation(
                          titulo: "Greek Yogurt",
                          timeToEat: "Snack",
                          descripcion:
                              "High in protein and probiotics, Greek yogurt supports gut health and helps you feel full and satisfied between meals. It's a nutritious snack option that can be paired with fruit, nuts, or honey for added flavor.")
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
