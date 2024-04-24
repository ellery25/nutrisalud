// ignore_for_file: avoid_print, file_names

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nutrisalud/Screens/Community.dart';
import '../Helpers/HelpersExport.dart';
import '../Providers/Preferences/UsuarioPreferences.dart';
import '../Providers/CommentsProviders.dart';

class PostCommunity extends StatefulWidget {
  const PostCommunity({super.key});

  @override
  State<PostCommunity> createState() => _PostCommunityState();
}

class _PostCommunityState extends State<PostCommunity> {
  final TextEditingController _contenidoController = TextEditingController();
  String userId = '';
  bool setCommunityVisited = false;

  @override
  void initState() {
    super.initState();
    _cargarUserId();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsConstants.whiteColor,
      appBar: AppBar(
        actions: [
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: ElevatedButton(
              onPressed: () async {
                // Verificar que el campo de texto no esté vacío
                if (_contenidoController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        title: const Text(
                          "Error",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: ColorsConstants.darkGreen,
                          ),
                        ),
                        content: const Text(
                          "El contenido del comentario no puede estar vacío",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: ColorsConstants.darkGreen,
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsConstants.darkGreen,
                            ),
                            child: const Text(
                              "Continuar",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: ColorsConstants.whiteColor,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Publicar el comentario
                try {
                  // Fecha actual en stgring

                  Map<String, dynamic> nuevoComentario = {
                    'contenido': _contenidoController.text,
                    'horas': DateTime.now().toString(),
                    'usuario':
                        'https://unilibremovil2-default-rtdb.firebaseio.com/usuarios/$userId.json',
                  };
                  print(DateTime.now().toString());

                  await Comentario.postComentario(nuevoComentario);

                  // Borrar el contenido del campo de texto
                  _contenidoController.clear();

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        title: const Text(
                          "Comentario añadido",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: ColorsConstants.darkGreen,
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsConstants.darkGreen,
                            ),
                            child: const Text(
                              "Continuar",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: ColorsConstants.whiteColor,
                              ),
                            ),
                            onPressed: () {
                              GetStorage().write('communityVisited', false);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Community()),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                } catch (e) {
                  // Manejo de errores
                  print('Error al publicar el comentario: $e');
                }
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith(
                      (states) => ColorsConstants.darkGreen)),
              child: const Text('Post comment',
                  style: TextStyle(
                      color: ColorsConstants.whiteColor,
                      fontWeight: FontWeight.w500)),
            ),
          )
        ],
        foregroundColor: ColorsConstants.darkGreen,
        backgroundColor: ColorsConstants.whiteColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contenidoController,
          style: const TextStyle(decoration: TextDecoration.none),
          expands: true,
          // Establecer maxLines en null para que TextField pueda crecer según sea necesario
          maxLines: null,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Contenido del comentario',
          ),
        ),
      ),
    );
  }
}
