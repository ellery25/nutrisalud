import 'package:flutter/material.dart';
import '../Widgets/CommunityWidgets/CommunityPost.dart';
import '../Widgets/GeneralWidgets/NavBar.dart';
import '../Providers/CommentsProviders.dart';
import '../Helpers/HelpersExport.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  List<Widget> comunityPostsList = [];
  final TextEditingController _userIDController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();
  final TextEditingController _horasController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();
  bool isLoading = true; // Nuevo estado para indicar si se está cargando

  @override
  void initState() {
    super.initState();
    llenarCommunityPostsList();
    // Prueba de la lista de usuarios
    print("Se ejecuta Llenar comunity posts");
  }

  Future<void> llenarCommunityPostsList() async {
    setState(() {
      isLoading = true;
    });
    print('Llenando la lista de community posts');
    final List<Comentario> comentarios = await Comentario.getComentarios();
    setState(() {
      comunityPostsList.addAll(comentarios.map((comentario) {
        return CommunityPost(
          horas: comentario.horas,
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
          print("Floating Button");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                scrollable: true,
                title: const Text(
                  "Nuevo comentario",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: ColorsConstants.darkGreen,
                  ),
                ),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _userIDController,
                        decoration: const InputDecoration(
                          labelText: 'UserID',
                          icon: Icon(Icons.account_box),
                        ),
                      ),
                      TextFormField(
                        controller: _contenidoController,
                        decoration: const InputDecoration(
                          labelText: 'Contenido',
                          icon: Icon(Icons.message),
                          focusColor: ColorsConstants.darkGreen,
                        ),
                        maxLines: 3,
                      ),
                      TextFormField(
                        controller: _horasController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Horas',
                          icon: Icon(Icons.lock_clock),
                          focusColor: ColorsConstants.darkGreen,
                        ),
                      ),
                      TextFormField(
                        controller: _fotoController,
                        decoration: const InputDecoration(
                          labelText: 'Foto (Opcional)',
                          icon: Icon(Icons.message),
                          focusColor: ColorsConstants.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsConstants.darkGreen,
                    ),
                    child: const Text("Añadir"),
                    onPressed: () async {
                      // Hacer el post
                      try {
                        Map<String, dynamic> nuevoComentario = {
                          'contenido': _contenidoController.text ??
                              (throw Exception('Error en contenido')),
                          'foto': _fotoController.text == ''
                              ? null
                              : _fotoController.text,
                          'horas': int.parse(_horasController.text) ??
                              (throw Exception('Error en horas')),
                          'usuario': _userIDController.text ??
                              (throw Exception('Error en usuario')),
                        };

                        await Comentario.postComentario(nuevoComentario);

                        // Borrar los contenidos de los campos de texto
                        _userIDController.clear();
                        _contenidoController.clear();
                        _horasController.clear();
                        _fotoController.clear();

                        Navigator.pop(context);

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
                                  child: const Text("Continuar"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );

                        //Actualizar la lista de comentarios
                        final List<Comentario> comentarios =
                            await Comentario.getComentarios();

                        setState(() {
                          // Limpiar la lista existente
                          comunityPostsList.clear();
                          // Volver a llenar la lista con los comentarios actualizados
                          comunityPostsList
                              .addAll(comentarios.map((comentario) {
                            return CommunityPost(
                              horas: comentario.horas,
                              contenido: comentario.contenido,
                              username: comentario.usuario,
                              nombre: comentario.nombre,
                            );
                          }));
                        });
                      } catch (e) {
                        print('Error en post de comentario: $e');
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              title: const Text(
                                "Error al añadir comentario",
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
                                  child: const Text("Continuar"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              );
            },
          );
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
