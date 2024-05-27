import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrisalud/Preferences/save_load.dart';
import 'package:flutter/material.dart';
import 'package:nutrisalud/Providers/nutritionists_providers.dart';
import 'package:nutrisalud/Providers/validate_jwt.dart';
import 'package:nutrisalud/Widgets/MainPageWidgets/main_page_blocks.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:nutrisalud/Providers/protips_provider.dart';
import 'package:nutrisalud/Providers/users_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';

// TODO: Darle alguna funcion a EatingTimeBlock
// TODO: Hacer el get de Community Posts guardarlos en cache y luego hacerlo manual con boton de recargar
// TODO: Hacer el get de Nutricionist guardarlos en cache y luego hacerlo manual con boton de recargar

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Controladores de texto
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Variables de session
  String isNutricionist = "false";
  String userId = '';

  // Variables de ProTips
  List<Widget> professionalTipsList = [];
  bool isLoading = true;

  // Variables de datos de sesión
  String dato1Sesion = '';
  String dato2Sesion = '';

  // Datos en cache
  bool firstTime = true;

  @override
  void initState() {
    super.initState();

    // ↓ Validate JWT ↓
    validateJWT();
    // ↑ Validate JWT ↑

    // ↓ Load in cache ↓
    cargarFirstTimeMainPage().then((_) {
      if (firstTime) {
        cargarProTipsList();
      } else {
        isLoading = false;

        // Leer y deserializar los datos almacenados
        List<dynamic> storedList = GetStorage().read('professionalTipsList');
        professionalTipsList = storedList
            .map<Widget>((item) => ProfessionalTipsBlock.fromJson(item))
            .toList();
      }
    });
    // ↑ Load in cache ↑

    cargarIsNutricionist();
    cargarUserId().then((_) {
      buscarInformacionSesion();
    });
  }

  validateJWT() async {
    // Obtener el token
    String? loadToken = await SharedPreferencesHelper.loadData('access_token');
    if (loadToken == null) {
      // Si no hay token, redirigir a la pantalla de bienvenida
      print('No hay token');
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    } else {
      // Validar el token
      if (await ValidateJWT.getValidateJWT(loadToken)) {
        // Si el token es válido, continuar
        print('Token válido');
      } else {
        // Si el token no es válido, redirigir a la pantalla de bienvenida
        print('Token inválido');
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      }
    }
  }

  cargarIsNutricionist() async {
    // Obtener el isNutricionist
    String? isNutricionist = await SharedPreferencesHelper.loadData('type');
    // Actualizar el estado para reflejar el userId
    if (isNutricionist != "user") {
      setState(() {
        this.isNutricionist = "true";
      });
    }
  }

  cargarUserId() async {
    // Obtener el userId
    String? userId = await SharedPreferencesHelper.loadData('userId');
    // Actualizar el estado para reflejar el userId
    setState(() {
      this.userId = userId!;
    });
  }

  cargarFirstTimeMainPage() async {
    // Obtener el firstTime
    bool? firstTime = GetStorage().read('firstTimeMainPage') ?? true;
    // Actualizar el estado para reflejar firstTime
    setState(() {
      this.firstTime = firstTime;
    });
  }

  Future<void> cargarProTipsList() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? loadToken =
          await SharedPreferencesHelper.loadData('access_token');
      if (loadToken == null) {
        throw Exception('No hay token');
      }

      final List<ProTip> proTips = await ProTip.getProTips(loadToken);

      List<Future<ProfessionalTipsBlock>> futureTips =
          proTips.map((proTip) async {
        Map<String, dynamic> nutritionist =
            await Nutritionist.getNutritionistById(
          proTip.nutritionist_id,
          loadToken,
        );

        return ProfessionalTipsBlock(
          title: proTip.title,
          tip: proTip.content,
          photo: nutritionist['photo'],
        );
      }).toList();

      List<ProfessionalTipsBlock> tips = await Future.wait(futureTips);

      setState(() {
        professionalTipsList = tips;
        isLoading = false;

        // Serializar los datos antes de almacenarlos
        List<Map<String, dynamic>> serializedList =
            tips.map((tip) => tip.toJson()).toList();
        GetStorage().write('professionalTipsList', serializedList);
        GetStorage().write('firstTimeMainPage', false);
      });
    } catch (e) {
      print('Error al obtener los ProTips: $e');
    }
  }

  Future<void> buscarInformacionSesion() async {
    String? loadToken = await SharedPreferencesHelper.loadData('access_token');
    if (isNutricionist == "true") {
      //Get para nutricionista
      final nutricionista =
          await Nutritionist.getNutritionistById(userId, loadToken!);
      print(nutricionista['name']);
      setState(() {
        dato1Sesion = nutricionista['name'];
        dato2Sesion = nutricionista['email'];
      });
    } else {
      //Get para usuario

      final usuario = await User.getUserById(loadToken!, userId);
      setState(() {
        dato1Sesion = usuario['name'];
        dato2Sesion = usuario['username'];
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: screenHeight * 0.3,
                      child: AlertDialog(
                        title: const Text(
                          'Add a ProTip',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: ColorsConstants.darkGreen),
                        ),
                        content: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _titleController,
                              decoration:
                                  const InputDecoration(hintText: "Título"),
                            ),
                            TextFormField(
                              controller: _contentController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                  hintText: "Contenido",
                                  border: InputBorder.none),
                            )
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () {
                              _contentController.clear();
                              _titleController.clear();
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Añadir'),
                            onPressed: () async {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  'Posting ProTip...',
                                  style: TextStyle(
                                      color: ColorsConstants.whiteColor),
                                ),
                                duration: Duration(seconds: 1),
                                backgroundColor: ColorsConstants.darkGreen,
                              ));
                              try {
                                String? loadToken =
                                    await SharedPreferencesHelper.loadData(
                                        'access_token');
                                if (loadToken == null) {
                                  throw Exception('No hay token');
                                }
                                await ProTip.postProTip(
                                    loadToken,
                                    _titleController.text,
                                    _contentController.text,
                                    userId);
                              } catch (e) {
                                print('Failed to post ProTip: $e');
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    'Failed to post ProTip',
                                    style: TextStyle(
                                        color: ColorsConstants.whiteColor),
                                  ),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: ColorsConstants.darkGreen,
                                ));
                              } finally {
                                Navigator.of(context).pop();
                                _contentController.clear();
                                _titleController.clear();
                              }

                              try {
                                await cargarProTipsList();
                              } catch (e) {
                                print('Failed to load ProTips: $e');
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
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
                              isLoading = true;
                              cargarProTipsList();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Icon(
                                Icons.sync,
                                size: 24,
                                color: Color(0xff3A5A40),
                              ),
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
                                color: ColorsConstants.darkGreen,
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
                dato2Sesion,
                style: const TextStyle(
                  color: ColorsConstants.darkGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: screenHeight * 0.42),
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
                        // Delete Session data
                        await SharedPreferencesHelper.saveData('userId', "");
                        await SharedPreferencesHelper.saveData(
                            'access_token', "");

                        // Delete Cache
                        //MainPage
                        GetStorage().remove('firstTimeMainPage');
                        GetStorage().remove('professionalTipsList');
                        //Nutricionists
                        GetStorage().remove('firstTimeNutritionistsPage');
                        GetStorage().remove('nutricardsList');
                        //Community
                        GetStorage().remove('firstTimeCommunityPage');
                        GetStorage().remove('communityPostsList');

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
