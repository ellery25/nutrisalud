// ignore_for_file: avoid_print, file_names

import 'package:flutter/material.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../Widgets/CommunityWidgets/CommunityPost.dart';
import '../Widgets/GeneralWidgets/NavBar.dart';
import '../Providers/CommentsProviders.dart';
import '../Helpers/HelpersExport.dart';
import '../Providers/Preferences/IsNutricionist.dart';
import '../Providers/Preferences/UsuarioPreferences.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  List<Widget> comunityPostsList = [];
  bool isLoading = true;
  String userId = '';
  bool isNutricionist = false;

  @override
  void initState() {
    super.initState();
    llenarCommunityPostsList();
    _cargarUserId();
    _cargarIsNutricionist();
  }

  _cargarUserId() async {
    // Pedir la variable de userId de las preferencias del usuario
    UserPersistence userPersistence = await UserPersistence.getInstance();
    // Obtener el userId
    String userId = userPersistence.getUser('userId');
    // Actualizar el estado para reflejar el userId
    setState(() {
      this.userId = userId;
    });

    print('userId: $userId');
  }

  _cargarIsNutricionist() async {
    // Pedir la variable de userId de las preferencias del usuario
    IsNutricionist userIsANutricionist = await IsNutricionist.getInstance();
    // Obtener el userId
    bool isNutricionist =
        userIsANutricionist.getIsNutricionist('isNutricionist?');
    // Actualizar el estado para reflejar el userId
    setState(() {
      this.isNutricionist = isNutricionist;
    });

    print('isNutricionist: $isNutricionist');
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
          userIdWidget: comentario.usuarioId,
          funcionEliminar: () {
            Comentario.deleteComentario(
                'https://unilibremovil2-default-rtdb.firebaseio.com/comentarios/${comentario.id}.json');
          },
        );
      }));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Si la variable isNutricionist es false, mostrar el botón flotante
      floatingActionButton: isNutricionist == false
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.postCommunity);
              },
              backgroundColor: ColorsConstants.darkGreen,
              child: const Icon(Icons.add, color: ColorsConstants.whiteColor),
            )
          : null,
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
