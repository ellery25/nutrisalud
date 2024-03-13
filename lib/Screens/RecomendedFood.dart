import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../Widgets/GeneralWidgets/GeneralBlocks.dart';
import 'package:flutter/material.dart';
import 'package:nutrisalud/Widgets/RecommendedFoodWidgets/FoodRecomendation.dart';
import '../Helpers/HelpersExport.dart';
import '../Providers/Preferences/IsNutricionist.dart';

class RecommendedFood extends StatefulWidget {
  const RecommendedFood({super.key});

  @override
  State<RecommendedFood> createState() => _RecommendedFoodState();
}

class _RecommendedFoodState extends State<RecommendedFood> {

  @override
  void initState() async {
    // TODO: implement initState
    super.initState();
    isNutricionist userIsANutricionist = await isNutricionist.getInstance();
    bool userIs = userIsANutricionist.getIsNutricionist('isNutricionist?');
    print(userIs);
  }

  @override
  Widget build(BuildContext context) {

    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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

