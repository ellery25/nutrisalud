import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrisalud/Preferences/save_load.dart';
import 'package:flutter/material.dart';
import 'package:nutrisalud/Widgets/MainPageWidgets/main_page_blocks.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:nutrisalud/Providers/protips_provider.dart';
import 'package:nutrisalud/Providers/nutricionists_providers.dart';
import 'package:nutrisalud/Providers/users_providers.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: Eating time te redirigen a una pagina donde puedes cambiar el la comida y se guarda local
// TODO: Hacer get de Protips solo la primara vez que si inicializa la pantalla, luego se hace manual con boton de recargar
// TODO: Hacer el get de Community Posts guardarlos en cache y luego hacerlo manual con boton de recargar
// TODO: Hacer el get de Nutricionist guardarlos en cache y luego hacerlo manual con boton de recargar

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String isNutricionist = "false";
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
    llenarProTipsList();
  }

  _cargarIsNutricionist() async {
    // Obtener el isNutricionist
    String? isNutricionist =
        await SharedPreferencesHelper.loadData('isNutricionist');
    // Actualizar el estado para reflejar el userId
    setState(() {
      this.isNutricionist = isNutricionist!;
    });

    print('isNutricionist: $isNutricionist');
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

  Future<void> llenarProTipsList() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Obtener los ProTips
      List<ProTip> proTips = await ProTip.getProTips();

      // Actualizar el estado con los ProTips obtenidos
      setState(() {
        professionalTipsList.addAll(proTips.map((proTip) {
          return ProfessionalTipsBlock(
            title: proTip.titulo,
            tip: proTip.contenido,
            nutricionistAvatar: proTip.foto,
          );
        }));

        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener los ProTips: $e');
      // Manejar el error, si es necesario
    }
  }

  Future<void> buscarInformacionSesion() async {
    print('Buscando información de la sesión');
    if (isNutricionist == "true") {
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
      floatingActionButton: isNutricionist == "true"
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
                      food: 'Sancocho de mondongo',
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
                    isLoading
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
                            children: professionalTipsList,
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
              isNutricionist == "true"
                  ? SvgPicture.asset(
                      AssetsRoutes.logoSvg,
                      color: ColorsConstants.darkGreen,
                      height: screenHeight * 0.15,
                    )
                  : Icon(
                      Icons.account_circle_outlined,
                      size: screenHeight * 0.15,
                      color: ColorsConstants.darkGreen,
                    ),
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
                "@$dato2Sesion",
                style: const TextStyle(
                  color: ColorsConstants.darkGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: screenHeight * 0.25),
              Container(
                width: screenWidth * 0.9,
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await launchUrl(Uri.parse(
                            'https://github.com/ellery25/nutrisalud'));
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => ColorsConstants.whiteColor),
                        shadowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'About this project',
                            style: TextStyle(
                              color: ColorsConstants.darkGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          SvgPicture.asset(
                            AssetsRoutes.githubSvg,
                            color: ColorsConstants.darkGreen,
                            width: 24,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await SharedPreferencesHelper.saveData('userId', "");
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(
                            currentContext, AppRoutes.welcome);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => ColorsConstants.whiteColor),
                        shadowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Log out',
                            style: TextStyle(
                              color: Color(0xFFE95858),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          const Icon(
                            Icons.logout,
                            size: 14,
                            color: Color(0xFFE95858),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
