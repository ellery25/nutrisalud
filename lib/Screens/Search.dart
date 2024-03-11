import 'package:flutter/material.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../Widgets/GeneralWidgets/NavBar.dart';
import '../Widgets/SearchWidgets/RecipePreview.dart';
import '../Helpers/Colors.dart';

// Peticion de JSON de los nutricionistas

// Renderizado de la pagina
class Search extends StatefulWidget {
  const Search({super.key});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              NavBar(
                backButton: true,
                backRoute: () {
                  print("back search");
                  Navigator.popAndPushNamed(context, AppRoutes.home);
                },
              ),
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 40.0),
                        child: Row(children: [
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  "Try to look for...",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                    color: ColorsConstants.darkGreen,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 25.0),
                                child: Column(children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 20.0),
                                    child: Text(
                                      "Grilled Salmon",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600,
                                        color: ColorsConstants.darkGreen,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 20.0),
                                    child: Text(
                                      "Greek yogurt",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600,
                                        color: ColorsConstants.darkGreen,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Quinoa Salad",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                      color: ColorsConstants.darkGreen,
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Row(children: [
                          Text(
                            "Recipes",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: ColorsConstants.darkGreen,
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: RecipePreview(
                            foto: 'assets/imgs/PP_Example.jpg',
                            nombre: "Salmon filet",
                            descripcion:
                                "A delicious and nutritious choice, rich in Omega-3 fatty acids.",
                            calorias: 206,
                            proteinas: 22,
                            peso: 13),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: RecipePreview(
                            foto: 'assets/imgs/PP_Example.jpg',
                            nombre: "Salmon filet",
                            descripcion:
                                "A delicious and nutritious choice, rich in Omega-3 fatty acids.",
                            calorias: 206,
                            proteinas: 22,
                            peso: 13),
                      ),
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
