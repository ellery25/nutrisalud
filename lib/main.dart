import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrisalud/Preferences/save_load.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/nutrisalud_bt_bar.dart';
import 'Screens/screens_export.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String?> rutaInicial;

  @override
  void initState() {
    super.initState();
    rutaInicial = definirRuta();
  }

  Future<String?> definirRuta() async {
    String? idUsuario = await SharedPreferencesHelper.loadData("userId");

    if (idUsuario == '' || idUsuario == null) {
      print("No hay usuario logueado");
      return AppRoutes.welcome;
    } else {
      print("Hay usuario logueado");
      return AppRoutes.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: ColorsConstants.whiteColor),
    );

    return FutureBuilder<String?>(
      future: rutaInicial,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading initial route"));
        } else {
          final rutaInicial = snapshot.data;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Nutrisalud',
            theme: ThemeData(
              colorScheme:
                  ColorScheme.fromSeed(seedColor: ColorsConstants.whiteColor),
              useMaterial3: true,
            ),
            initialRoute: rutaInicial,
            routes: {
              AppRoutes.home: (context) => const NutrisaludBtBar(),
              AppRoutes.nutricionist: (context) => const Nutricionists(),
              AppRoutes.welcome: (context) => const WelcomeScreen(),
              AppRoutes.introduction: (context) => const Introduction(),
              AppRoutes.chooseAccount: (context) => const ChooseAccount(),
              AppRoutes.register: (context) => const Register(),
              AppRoutes.login: (context) => const Login(),
              AppRoutes.introductionDoctor: (context) =>
                  const IntroductionDoctor(),
              AppRoutes.setPageNutricionist: (context) =>
                  const SetPageNutricionist(),
            },
          );
        }
      },
    );
  }
}
