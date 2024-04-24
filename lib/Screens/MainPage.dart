// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../Widgets/MainPageWidgets/MainPageBlocks.dart';
import '../Helpers/HelpersExport.dart';
import '../Providers/Preferences/UsuarioPreferences.dart';
import '../Providers/Preferences/IsNutricionist.dart';
import '../Providers/ProTipsProviders.dart';
import '../Providers/NutricionistsProviders.dart';
import '../Providers/UsersProviders.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> getProfessionalTipsList = [];
  List<Widget> localProfessionalTipsList = [];
  String userId = '';
  String dato1Sesion = '';
  String dato2Sesion = '';

  // GetX Variables
  RxBool hasBeenVisitedProTips = false.obs;
  RxBool isLoading = false.obs;
  RxBool isNutricionist = false.obs;

  @override
  void initState() {
    super.initState();
    _cargarIsNutricionist();
    _cargarUserId().then((_) {
      buscarInformacionSesion();
    });
    _checkVisitedStatus();
    llenarProTipsList();
    localProfessionalTipsList =
        GetStorage().read('localProfessionalTipsList') ?? [];
  }

  _checkVisitedStatus() {
    // Verificar si la página ya ha sido visitada antes
    hasBeenVisitedProTips.value = GetStorage().read('proTipsVisited') ?? false;

    // Si es la primera vez que se visita, actualizar el estado y guardar en GetStorage
    if (!hasBeenVisitedProTips.value) {
      setState(() {
        hasBeenVisitedProTips.value = false;
      });
      GetStorage().write('proTipsVisited', true);
    }
  }

  _cargarIsNutricionist() async {
    // Pedir la variable de userId de las preferencias del usuario
    IsNutricionist userIsANutricionist = await IsNutricionist.getInstance();
    // Obtener el userId
    bool isNutricionist =
        userIsANutricionist.getIsNutricionist('isNutricionist?');
    // Actualizar el estado para reflejar el userId
    setState(() {
      this.isNutricionist.value = isNutricionist;
    });

    print('isNutricionist: $isNutricionist');
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

  Future<void> llenarProTipsList() async {
    setState(() {
      isLoading.value = true;
    });

    try {
      // Obtener los ProTips
      List<ProTip> proTips = await ProTip.getProTips();

      // Actualizar el estado con los ProTips obtenidos
      setState(() {
        getProfessionalTipsList.clear();
        getProfessionalTipsList.addAll(proTips.map((proTip) {
          return ProfessionalTipsBlock(
            title: proTip.titulo,
            tip: proTip.contenido,
            nutricionistAvatar: proTip.foto,
          );
        }));

        isLoading.value = false;
      });
    } catch (e) {
      print('Error al obtener los ProTips: $e');
      // Manejar el error, si es necesario
    }

    GetStorage().write('localProfessionalTipsList', getProfessionalTipsList);
  }

  Future<void> buscarInformacionSesion() async {
    print('Buscando información de la sesión');
    if (isNutricionist.value) {
      //Get para nutricionista
      final nutricionista = await Nutricionistas.getNutricionista(
          'https://unilibremovil2-default-rtdb.firebaseio.com/nutricionistas/$userId.json');

      setState(() {
        dato1Sesion = nutricionista['nombre'];
        dato2Sesion = nutricionista['email'];
      });
    } else {
      //Get para usuario

      final usuario = await Usuario.getUsuario(
          'https://unilibremovil2-default-rtdb.firebaseio.com/usuarios/$userId.json');
      setState(() {
        dato1Sesion = usuario['nombre'];
        dato2Sesion = usuario['usuario'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    BuildContext currentContext = context;

    return Scaffold(
      // Si la variable isNutricionist es false, mostrar el botón flotante
      floatingActionButton: Obx(
        () => isNutricionist.value
            ? FloatingActionButton(
                onPressed: () {
                  // Acciones para añadir un profesional tip
                  Navigator.pushNamed(context, AppRoutes.postProTip);
                },
                backgroundColor: ColorsConstants.darkGreen,
                child: const Icon(Icons.add, color: ColorsConstants.whiteColor),
              )
            : const SizedBox.shrink(),
      ),

      backgroundColor: ColorsConstants.whiteColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MainPageBar(userAvatar: ''),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended eating times',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ColorsConstants.darkGreen,
                            ),
                          ),
                          Text(
                            'Based on your eating habits',
                            style: TextStyle(
                              fontSize: 20,
                              color: ColorsConstants.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Eating times
                    const EatingTimeBlock(
                      type: 'Breakfast',
                      food: 'Caesar Salad',
                      time: '7:00 - 9:00 AM',
                    ),
                    const EatingTimeBlock(
                      type: 'Lunch',
                      food: 'Chicken Soup',
                      time: '11:00 - 1:00 PM',
                    ),
                    const EatingTimeBlock(
                      type: 'Dinner',
                      food: 'Sancocho de mondongo',
                      time: '5:00 - 7:00 PM',
                    ),
                    //Professional Tips
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 7),
                      child: Row(
                        children: [
                          const Text(
                            'Professional Tips',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ColorsConstants.darkGreen,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              hasBeenVisitedProTips.value = false;
                              llenarProTipsList();
                              localProfessionalTipsList =
                                  GetStorage().read('localComunityPostsList') ??
                                      [];
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
                        ],
                      ),
                    ),
                    Obx(
                      () => !hasBeenVisitedProTips.value
                          ? isLoading.value
                              ? const Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          ColorsConstants.darkGreen),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: getProfessionalTipsList,
                                )
                          : Column(
                              children: localProfessionalTipsList,
                            ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: ColorsConstants.whiteColor,
        child: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.1),
          child: Column(
            children: [
              CircleAvatar(radius: screenHeight * 0.1),
              SizedBox(height: screenHeight * 0.02),
              Text(
                dato1Sesion,
                style: const TextStyle(
                  color: ColorsConstants.darkGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dato2Sesion,
                style: const TextStyle(
                  color: ColorsConstants.darkGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: screenHeight * 0.25),
              //Help, conditions and Share
              Container(
                width: screenWidth * 0.9,
                margin: EdgeInsets.only(right: screenWidth * 0.15),
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => ColorsConstants.whiteColor),
                        shadowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Help',
                            style: TextStyle(
                              color: ColorsConstants.darkGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          const Icon(
                            Icons.help_outline,
                            color: ColorsConstants.darkGreen,
                            weight: 1,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => ColorsConstants.whiteColor),
                        shadowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: ColorsConstants.darkGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          const Icon(
                            Icons.menu_book,
                            color: ColorsConstants.darkGreen,
                            weight: 1,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => ColorsConstants.whiteColor),
                        shadowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Share with friends',
                            style: TextStyle(
                              color: ColorsConstants.darkGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          const Icon(
                            Icons.share,
                            color: ColorsConstants.darkGreen,
                            weight: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      left: screenWidth * 0.5, bottom: screenHeight * 0.01),
                  alignment: Alignment.bottomRight,
                  child: Row(
                    children: [
                      const Text(
                        'Log out',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: ColorsConstants.darkGreen,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          UserPersistence userPersistence =
                              await UserPersistence.getInstance();
                          await userPersistence.setUser('userId', '');
                          Navigator.pushReplacementNamed(
                              currentContext, AppRoutes.welcome);
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: ColorsConstants.darkGreen,
                        ),
                      ),
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
