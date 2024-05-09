import 'package:flutter/material.dart';
import 'package:nutrisalud/Widgets/CommunityWidgets/community_post.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/NavBar.dart';
import 'package:nutrisalud/Providers/comments_providers.dart';
import 'package:nutrisalud/Preferences/save_load.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';

// TODO: Actualizar la lista de comentarios cuando se elimine un comentario

class Community extends StatefulWidget {
  const Community({super.key});
  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  List<Widget> communityPostsList = [];
  bool isLoading = true;
  String userId = '';
  String isNutricionist = "false";

  @override
  void initState() {
    super.initState();
    llenarCommunityPostsList();
    _cargarUserId();
    _cargarIsNutricionist();
  }

  _cargarUserId() async {
    // Obtener el userId
    String? userId = await SharedPreferencesHelper.loadData("userId");
    // Actualizar el estado para reflejar el userId
    setState(() {
      this.userId = userId!;
    });

    print('userId: $userId');
  }

  _cargarIsNutricionist() async {
    // Obtener el userId
    String? isNutricionist =
        await SharedPreferencesHelper.loadData("isNutricionist");

    // Actualizar el estado para reflejar el userId
    setState(() {
      this.isNutricionist = isNutricionist!;
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
      communityPostsList.addAll(comentarios.map((comentario) {
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
          functionEliminar: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AlertDialog(
                  title: Text(
                    'Procesing data',
                    style: TextStyle(
                      fontSize: 18,
                      color: ColorsConstants.darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SizedBox(
                    height: 50,
                    width: 50,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorsConstants.darkGreen,
                      ),
                    ),
                  ),
                );
              },
            );

            Comentario.deleteComentario(
                    'https://unilibremovil2-default-rtdb.firebaseio.com/comentarios/${comentario.id}.json')
                .then((_) {
              Navigator.of(context).pop();

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Comment deleted.',
                      style: TextStyle(
                        fontSize: 18,
                        color: ColorsConstants.darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsConstants.darkGreen,
                        ),
                        child: const Text("Continuar",
                            style: TextStyle(
                              fontSize: 18,
                              color: ColorsConstants.whiteColor,
                            )),
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Aqui colocar funcion para Actualizar la lista de comentarios
                        },
                      ),
                    ],
                  );
                },
              );
            });
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
      floatingActionButton: isNutricionist == "false"
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
                            color: ColorsConstants.darkGreen),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            ...communityPostsList,
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
