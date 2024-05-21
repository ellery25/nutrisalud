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
    llenarCommunityPostsList();
  }

  Future<void> llenarCommunityPostsList() async {
    print('Llenando la lista de community posts');
    try {
      final List<Meal>? recetas = await Meal.getMeals();
      if (mounted) {
        setState(() {
          // Construye la lista de widgets usando los datos de recetas

          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error al cargar las recetas: $error');
    }
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
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            ...foodPostsList,
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
