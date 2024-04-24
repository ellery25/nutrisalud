// ignore_for_file: avoid_print, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../Widgets/CommunityWidgets/CommunityPost.dart';
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
  List<Widget> getComunityPostsList = [];
  List<Widget> localComunityPostsList = [];
  String userId = '';
  bool isNutricionist = false;

  // GetX Variables
  RxBool hasBeenVisitedCommunity = false.obs;
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _cargarUserId();
    _cargarIsNutricionist();
    _checkVisitedStatus();
    llenarCommunityPostsList();
    localComunityPostsList = GetStorage().read('localComunityPostsList') ?? [];
  }

  _checkVisitedStatus() {
    // Verificar si la página ya ha sido visitada antes
    hasBeenVisitedCommunity.value =
        GetStorage().read('communityVisited') ?? false;

    // Si es la primera vez que se visita, actualizar el estado y guardar en GetStorage
    if (!hasBeenVisitedCommunity.value) {
      setState(() {
        hasBeenVisitedCommunity.value = false;
      });
      GetStorage().write('communityVisited', true);
    }
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
      isLoading.value = true;
    });
    print('Llenando la lista de community posts');
    final List<Comentario> comentarios = await Comentario.getComentarios();
    setState(() {
      getComunityPostsList.clear();
      getComunityPostsList.addAll(comentarios.map((comentario) {
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

            llenarCommunityPostsList();
            localComunityPostsList =
                GetStorage().read('getComunityPostsList') ?? [];
          },
        );
      }));
      isLoading.value = false;
    });

    // Guardar la lista de community posts en GetStorage
    GetStorage().write('localComunityPostsList', getComunityPostsList);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 34,
                    ),
                    const Spacer(),
                    const Text(
                      "Community",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 26.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff3A5A40),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        llenarCommunityPostsList();
                        hasBeenVisitedCommunity.value = false;
                        localComunityPostsList =
                            GetStorage().read('getComunityPostsList') ?? [];
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          Icons.refresh,
                          size: 24,
                          color: Color(0xff3A5A40),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 34,
                    ),
                  ],
                ),
              ),
              Obx(
                () => !hasBeenVisitedCommunity.value
                    ? Expanded(
                        child: isLoading.value
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ColorsConstants.darkGreen,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: getComunityPostsList,
                                ),
                              ),
                      )
                    : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: localComunityPostsList,
                          ),
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
