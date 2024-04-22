// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import 'package:nutrisalud/blocs/ProTips/ProTips_cubit.dart';
import '../Widgets/MainPageWidgets/MainPageBlocks.dart';
import '../Helpers/HelpersExport.dart';
import '../Providers/Preferences/UsuarioPreferences.dart';
import '../Providers/Preferences/IsNutricionist.dart';
import '../Providers/NutricionistsProviders.dart';
import '../Providers/UsersProviders.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isNutricionist = false;
  String userId = '';
  bool isLoading = true;
  List<Widget> professionalTipsList = [];
  String dato1Sesion = '';
  String dato2Sesion = '';

  @override
  void initState() {
    super.initState();
    _cargarIsNutricionist();
    _cargarUserId().then((_) {
      buscarInformacionSesion();
    });
    context.read<ProTipsBloc>().add(FetchProTips());
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

  Future<void> buscarInformacionSesion() async {
    print('Buscando información de la sesión');
    if (isNutricionist) {
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
      floatingActionButton: isNutricionist == true
          ? FloatingActionButton(
              onPressed: () {
                // Acciones para añadir un profesional tip
                Navigator.pushNamed(context, AppRoutes.postProTip);
              },
              backgroundColor: ColorsConstants.darkGreen,
              child: const Icon(Icons.add, color: ColorsConstants.whiteColor),
            )
          : null,

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
                      food: 'Grilled Salmon',
                      time: '5:00 - 7:00 PM',
                    ),
                    //Professional Tips
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 7),
                      child: const Row(
                        children: [
                          Text(
                            'Professional Tips',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ColorsConstants.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<ProTipsBloc, ProTipsState>(
                      builder: (context, state) {
                        if (state is ProtipsLoading) {
                          return const CircularProgressIndicator();
                        } else if (state is ProtipsLoaded) {
                          professionalTipsList
                              .addAll(state.protips.map((proTip) {
                            return ProfessionalTipsBlock(
                              title: proTip.titulo,
                              tip: proTip.contenido,
                              nutricionistAvatar: proTip.foto,
                            );
                          }));
                          return ListView(children: professionalTipsList);
                        } else if (state is ProtipsError) {
                          return Text(state.message);
                        }
                        return Container();
                      },
                    ),
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
