import 'package:flutter/material.dart';
import '../Widgets/CommunityWidgets/CommunityPost.dart';
import '../Widgets/GeneralWidgets/NavBar.dart';
import '../Providers/CommentsProviders.dart';

class Community extends StatefulWidget {
  const Community({Key? key}) : super(key: key);

  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  List<Widget> comunityPostsList = [];
  TextEditingController _userIDController = TextEditingController();
  TextEditingController _contenidoController = TextEditingController();
  TextEditingController _horasController = TextEditingController();
  TextEditingController _fotoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    llenarCommunityPostsList();
    // Prueba de la lista de usuarios
    print("Se ejecuta Llenar comunity posts");
  }

  Future<void> llenarCommunityPostsList() async {
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
      print('Lista comunityPostsList: $comunityPostsList');
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
                title: Text(
                  "Nuevo comentario",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff527450),
                  ),
                ),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _userIDController,
                        decoration: InputDecoration(
                          labelText: 'UserID',
                          icon: Icon(Icons.account_box),
                        ),
                      ),
                      TextFormField(
                        controller: _contenidoController,
                        decoration: InputDecoration(
                          labelText: 'Contenido',
                          icon: Icon(Icons.message),
                          focusColor: Color(0xff527450),
                        ),
                        maxLines: 3,
                      ),
                      TextFormField(
                        controller: _horasController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Horas',
                          icon: Icon(Icons.lock_clock),
                          focusColor: Color(0xff527450),
                        ),
                      ),
                      TextFormField(
                        controller: _fotoController,
                        decoration: InputDecoration(
                          labelText: 'Foto (Opcional)',
                          icon: Icon(Icons.message),
                          focusColor: Color(0xff527450),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff527450),
                    ),
                    child: Text("Añadir"),
                    onPressed: () async {
                      // Hacer el post
                      try {
                        Map<String, dynamic> nuevoComentario = {
                          'contenido': _contenidoController.text == null
                              ? throw Exception('Error en contenido')
                              : _contenidoController.text,
                          'foto': _fotoController.text == ''
                              ? null
                              : _fotoController.text,
                          'horas': int.parse(_horasController.text) == null
                              ? throw Exception('Error en horas')
                              : int.parse(_horasController.text),
                          'usuario': _userIDController.text == null
                              ? throw Exception('Error en usuario')
                              : _userIDController.text,
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
                              title: Text(
                                "Comentario añadido",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff527450),
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xff527450),
                                  ),
                                  child: Text("Continuar"),
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
                              title: Text(
                                "Error al añadir comentario",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff527450),
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xff527450),
                                  ),
                                  child: Text("Continuar"),
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
        backgroundColor: Color(0xff527450),
        child: const Icon(Icons.add),
      ),
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
