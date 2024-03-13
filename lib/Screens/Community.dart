// ignore_for_file: avoid_print, file_names

import 'package:flutter/material.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../Widgets/CommunityWidgets/CommunityPost.dart';
import '../Widgets/GeneralWidgets/NavBar.dart';
import '../Providers/CommentsProviders.dart';
import '../Helpers/HelpersExport.dart';
import '../Providers/Preferences/IsNutricionist.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  List<Widget> comunityPostsList = [];
  bool isLoading = true;


  @override
  void initState() async {
    super.initState();
    llenarCommunityPostsList();
    // Prueba de la lista de usuarios
    print("Se ejecuta Llenar comunity posts");
    isNutricionist userIsANutricionist = await isNutricionist.getInstance();
    bool userIs = userIsANutricionist.getIsNutricionist('isNutricionist?');
    print(userIs);
  }

  Future<void> llenarCommunityPostsList() async {
    setState(() {
      isLoading = true;
    });
    print('Llenando la lista de community posts');
    final List<Comentario> comentarios = await Comentario.getComentarios();
    setState(() {
      comunityPostsList.addAll(comentarios.map((comentario) {
        // Calcular la diferencia en horas
        int diferenciaEnHoras = DateTime.parse(DateTime.now().toString())
            .difference(DateTime.parse(comentario.horas))
            .inHours;

        return CommunityPost(
          horas: diferenciaEnHoras,
          contenido: comentario.contenido,
          username: comentario.usuario,
          nombre: comentario.nombre,
        );
      }));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.postCommunity);
        },
        backgroundColor: ColorsConstants.darkGreen,
        child: const Icon(Icons.add, color: ColorsConstants.whiteColor),
      ),
      backgroundColor: ColorsConstants.whiteColor,
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
                },
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ColorsConstants.darkGreen)),
                      )
                    : SingleChildScrollView(
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
