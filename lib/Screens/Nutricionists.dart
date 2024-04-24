// ignore: file_names
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/GeneralBlocks.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import '../Widgets/NutricionistWidgets/NutriCard.dart';
import '../Helpers/HelpersExport.dart';
import '../Providers/NutricionistsProviders.dart';

class Nutricionists extends StatefulWidget {
  const Nutricionists({super.key});

  @override
  _NutricionistsState createState() => _NutricionistsState();
}

class _NutricionistsState extends State<Nutricionists> {
  late int selectedPage;
  late final PageController _pageController;

  List<Widget> nutricardsList = [];
  int pageCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    selectedPage = 0;
    _pageController = PageController(initialPage: selectedPage);
    _loadNutricionistas();
    super.initState();
  }

  void _loadNutricionistas() async {
    try {
      List<Nutricionistas> nutricionistas =
          await Nutricionistas.getNutricionistas();

      // Iterar la lista de usuarios para mostrar todos los nutricionistas y sus datos
      /*
      for (var element in nutricionistas) {
        // Imprimir todos los datos de cada uno de los elementos
        print('Nombre: ${element.nombre}');
        print('Descripción: ${element.descripcion}');
        print('Calificación: ${element.calificacion}');
        print('Foto: ${element.foto}');
        print('Skill 1: ${element.skill_1}');
        print('Skill 2: ${element.skill_2 ?? 'No tiene'}');
        print('Skill 3: ${element.skill_3 ?? 'No tiene'}');
        print('Email: ${element.email}');
        print('Instagram: ${element.instagram ?? 'No tiene'}');
        print('Whatsapp: ${element.whatsapp ?? 'No tiene'}');
        print('Website: ${element.web_site}');
        print('----------------------');
      }
      */
      setState(() {
        nutricardsList = nutricionistas.map((nutricionista) {
          return NutriCard(
            nombre: nutricionista.nombre,
            descripcion: nutricionista.descripcion,
            calificacion: nutricionista.calificacion,
            foto: nutricionista.foto,
            skill_1: nutricionista.skill_1,
            skill_2: nutricionista.skill_2,
            skill_3: nutricionista.skill_3,
            email: nutricionista.email,
            instagram: nutricionista.instagram,
            whatsapp: nutricionista.whatsapp,
            web_site: nutricionista.web_site,
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
      backgroundColor: Colors.white,
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ColorsConstants.darkGreen)))
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
