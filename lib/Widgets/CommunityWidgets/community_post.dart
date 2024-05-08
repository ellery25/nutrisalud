import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:nutrisalud/Preferences/save_load.dart';
import 'package:get/get.dart';

class CommunityPost extends StatefulWidget {
  final String contenido;
  final String? foto;
  final int horas;
  final String nombre;
  final String username;
  final String userIdWidget;
  final VoidCallback functionEliminar;

  const CommunityPost(
      {super.key,
      this.foto,
      required this.horas,
      required this.contenido,
      required this.username,
      required this.nombre,
      required this.userIdWidget,
      required this.functionEliminar});

  @override
  State<CommunityPost> createState() => _CommunityPostState();
}

class _CommunityPostState extends State<CommunityPost> {
  String userId = '';
  bool isNutricionist = false;

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
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 2.0, color: Color(0xffE3E3E3)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.nombre,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: ColorsConstants.darkGreen,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '@${widget.username}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                        color: ColorsConstants.darkGreen,
                      ),
                    ),
                    const Spacer(),
                    const Spacer(),
                    Text(
                      '${widget.horas}h',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                        color: ColorsConstants.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                widget.contenido,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: ColorsConstants.darkGreen,
                ),
              ),
              if (widget.foto != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    width: screenWidth * 0.80,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                      border: Border.all(color: ColorsConstants.darkGreen),
                    ),
                    child: Center(
                      child: Image.asset(widget.foto!),
                    ),
                  ),
                ),
              ],
              if ('https://unilibremovil2-default-rtdb.firebaseio.com/usuarios/$userId.json' ==
                  widget.userIdWidget) ...[
                // Boton de borrar
                Container(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                      onPressed: () {
                        // Delete del comentario
                        widget.functionEliminar();

                        // Mostrar un snackbar
                        Get.snackbar("Aviso", "Comentario eliminado");
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: ColorsConstants.darkGreen,
                      )),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
