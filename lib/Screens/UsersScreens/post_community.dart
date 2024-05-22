import 'package:nutrisalud/Preferences/save_load.dart';
import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:nutrisalud/Providers/comments_providers.dart';
import 'package:http/http.dart' as http;
import 'package:nutrisalud/Screens/UsersScreens/Community.dart';

// TODO: Recargar lista de comentario luego de crear un comentario nuevo

class PostCommunity extends StatefulWidget {
  const PostCommunity({super.key});

  @override
  State<PostCommunity> createState() => _PostCommunityState();
}

class _PostCommunityState extends State<PostCommunity> {
  final TextEditingController _contenidoController = TextEditingController();
  String userId = '';

  @override
  void initState() {
    super.initState();
    _cargarUserId();
  }

  _cargarUserId() async {
    // Obtener el userId
    String? userId = await SharedPreferencesHelper.loadData('userId');
    // Actualizar el estado para reflejar el userId
    setState(() {
      this.userId = userId!;
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
                        title: const Text("The comment can't be empty",
                            style: TextStyle(
                              fontSize: 18,
                              color: ColorsConstants.darkGreen,
                              fontWeight: FontWeight.bold,
                            )),
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
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                try {
                  String? loadToken =
                      await SharedPreferencesHelper.loadData('access_token');
                  Map<String, dynamic> nuevoComentario = {
                    'content': _contenidoController.text,
                    'photo': '',
                    'timestamp': DateTime.now().toString(),
                    'user_id': await SharedPreferencesHelper.loadData('userId'),
                  };
                  print(DateTime.now().toString());

                  http.Response response =
                      await Comment.postComment(nuevoComentario, loadToken!);

                  if (response.statusCode == 201) {
                    // Borrar el contenido del campo de texto
                    _contenidoController.clear();

                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          title: const Text("Comment added",
                              style: TextStyle(
                                fontSize: 18,
                                color: ColorsConstants.darkGreen,
                                fontWeight: FontWeight.bold,
                              )),
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
                              onPressed: ()  async {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Manejo de errores
                    print(
                        'Error al publicar el comentario: ${response.statusCode}');
                  }
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
