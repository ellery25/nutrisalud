import 'package:flutter/material.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import 'package:nutrisalud/Widgets/CommunityWidgets/CommunityPost.dart';
import '../Widgets/GeneralWidgets/NavBar.dart';

class Community extends StatelessWidget {
  const Community({super.key});
  @override
  Widget build(BuildContext context) {

    List<Widget> comunityPostsList = [
      CommunityPost(
        horas: 2,
        contenido:
        "El pescado azul es rico en nutrientes importantes de los que muchas personas carecen: yodo, proteínas de alta calidad y varias vitaminas y minerales.",
        username: "valplata",
        nombre: "Tina",
      ),
      CommunityPost(
        foto: 'assets/imgs/post_1.jpg',
        horas: 1,
        contenido:
        "Descubrí una nueva receta hoy. ¡Pollo asado con hierbas frescas! Tan delicioso y fácil de hacer.",
        username: "foodie101",
        nombre: "Chef Coco",
      ),
      CommunityPost(
        horas: 4,
        contenido:
        "Explorando nuevos lugares y descubriendo culturas fascinantes. La vida es una aventura.",
        username: "wanderlust",
        nombre: "Aventurero",
      ),
      CommunityPost(
        horas: 3,
        contenido: "¡Miren a este adorable cachorro! 🐾 ¡Nueva adición a la familia!",
        username: "petlover",
        nombre: "Amante",
      ),
      CommunityPost(
        foto: 'assets/imgs/post_2.jpg',
        horas: 5,
        contenido:
        "Entrenamiento matutino completado. 💪 ¡No hay excusas para no cuidar de tu salud!",
        username: "fitlife",
        nombre: "EntuFitness",
      ),
    ];


    int pageCount = comunityPostsList.length;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              NavBar(
                backButton: false,
                title: "Community",
                backRoute: () {
                  print("Back Community");
                  Navigator.popAndPushNamed(context, AppRoutes.home);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...comunityPostsList,
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
