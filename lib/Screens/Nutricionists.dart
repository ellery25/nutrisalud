import 'package:flutter/material.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/GeneralBlocks.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'NutriCard.dart';
import '../Helpers/Colors.dart';

// Peticion de JSON de los nutricionistas

// Renderizado de la pagina
class Nutricionists extends StatefulWidget {
  const Nutricionists({super.key});
  @override
  _NutricionistsState createState() => _NutricionistsState();
}

class _NutricionistsState extends State<Nutricionists> {
  // Controladores de Page dot indicator
  late int selectedPage;
  late final PageController _pageController;

  @override
  void initState() {
    // Controladores de Page dot indicator
    selectedPage = 0;
    _pageController = PageController(initialPage: selectedPage);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Lista de Nutricards
    List<Widget> nutricardsList = [
      const NutriCard(
        nombre: "Dr. Marlon José",
        descripcion:
            "Nutricionista especializado en dietas personalizadas para mejorar la salud y el rendimiento físico.",
        calificacion: 4.5,
        foto: "assets/imgs/dr_1.jpg",
        skill_1: "Planificación de dietas",
        email: "melo.jose@example.com",
        instagram: "melojose_nutri",
        whatsapp: "+573045360092",
        web_site: "https://www.melojose.com",
      ),
      const NutriCard(
        nombre: "Dr. Matta",
        descripcion:
            "Experto en nutrición deportiva y pérdida de peso. Ayudo a mis pacientes a alcanzar sus metas.",
        foto: "assets/imgs/dr_2.jpg",
        calificacion: 4.8,
        skill_1: "Nutrición deportiva",
        skill_3: "Pérdida de peso",
        email: "matta@example.com",
        instagram: "dr_matta_nutri",
        whatsapp: "+573045364492",
        web_site: "https://www.drmatta.com",
      ),
      const NutriCard(
        nombre: "Dra. Smith",
        descripcion:
            "Especialista infantil. Ayudo a los padres a dar una alimentación saludable para sus hijos.",
        foto: "assets/imgs/dr_3.jpg",
        calificacion: 4.2,
        skill_1: "Nutrición infantil",
        email: "dra.smith@example.com",
        instagram: "dra_smith_nutri",
        whatsapp: "+573045376890",
        web_site: "https://www.drasmithnutrition.com",
      ),
      const NutriCard(
        nombre: "Lic. García",
        descripcion:
            "Dietista experto en control de peso y mejora de hábitos alimenticios. ¡Juntos lograremos tus objetivos!",
        foto: "assets/imgs/dr_4.jpg",
        calificacion: 4.6,
        skill_1: "Control de peso",
        skill_3: "Hábitos alimenticios",
        email: "lic.garcia@example.com",
        instagram: "lic_garcia_nutri",
        whatsapp: "+573045388765",
        web_site: "https://www.licgarcia.com",
      ),
    ];

    int pageCount = nutricardsList.length;

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorsConstants.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NavBar(
                backButton: false,
                backRoute: () {},
                title: 'Nutricionists',
              ),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      // Swipe hacia la derecha
                      if (selectedPage > 0) {
                        setState(() {
                          selectedPage--;
                        });
                        _pageController.animateToPage(
                          selectedPage,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      }
                    } else if (details.primaryVelocity! < 0) {
                      // Swipe hacia la izquierda
                      if (selectedPage < pageCount - 1) {
                        setState(() {
                          selectedPage++;
                        });
                        _pageController.animateToPage(
                          selectedPage,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  },
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        selectedPage = page;
                      });
                    },
                    children: List.generate(pageCount, (index) {
                      return Center(
                        child: nutricardsList[index],
                      );
                    }),
                  ),
                ),
              ),
              PageViewDotIndicator(
                currentItem: selectedPage,
                count: pageCount,
                unselectedColor: Colors.black26,
                selectedColor: const Color(0xff3A5A40),
                duration: const Duration(milliseconds: 200),
                onItemClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
