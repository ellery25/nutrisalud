import 'package:flutter/material.dart';
import 'package:nutrisalud/Preferences/save_load.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/general_blocks.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:nutrisalud/Widgets/NutritionistWidgets/NutriCard.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:nutrisalud/Providers/nutritionists_providers.dart';

class Nutricionists extends StatefulWidget {
  const Nutricionists({super.key});
  @override
  State<Nutricionists> createState() => _NutricionistsState();
}

class _NutricionistsState extends State<Nutricionists> {
  late int selectedPage;
  late final PageController _pageController;

  List<Widget> nutricardsList = [
    const Nutricard(
      nombre: "Dr. Marlon José",
      descripcion:
          "Nutricionista especializado en dietas personalizadas para mejorar la salud y el rendimiento físico.",
      calificacion: "4.5",
      foto: "assets/imgs/dr_1.jpg",
      skill_1: "Planificación de dietas",
      email: "melo.jose@example.com",
      instagram: "melojose_nutri",
      whatsapp: "+573045360092",
      webSite: "www.melojose.com",
    )
  ];
  int pageCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    selectedPage = 0;
    _pageController = PageController(initialPage: selectedPage);
    loadNutricionistas();
    super.initState();
  }

  Future<void> loadNutricionistas() async {
    try {
      String? loadToken = await SharedPreferencesHelper.loadData('access_token');
      List<Nutritionist> nutricionistas =
          await Nutritionist.getNutricionists(loadToken!);
          
      setState(() {
        nutricardsList = nutricionistas.map((nutricionista) {
          return Nutricard(
            nombre: nutricionista.name,
            descripcion: nutricionista.description,
            calificacion: nutricionista.rating,
            foto: nutricionista.photo,
            skill_1: nutricionista.skill1,
            skill_2: nutricionista.skill2,
            skill_3: nutricionista.skill3,
            email: nutricionista.email,
            instagram: nutricionista.instagram,
            whatsapp: nutricionista.whatsapp,
            webSite: nutricionista.website!,
          );
        }).toList();
        pageCount = nutricardsList.length; // Actualiza pageCount
        isLoading = false;
      });
    } catch (e) {
      print("Error al cargar los nutricionistas en screen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Usar un FutureBuilder para mostrar el indicador de carga
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: ColorsConstants.darkGreen,
                      ))
                    : GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity! > 0) {
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
              if (pageCount > 0) // Verifica que haya al menos una página
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
