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
  String rutaInicial = AppRoutes.welcome;

  @override
  void initState() {
    definirRuta();
    super.initState();
  }

  void definirRuta() async {
    String? idUsuario = await SharedPreferencesHelper.loadData("userId");

    if (idUsuario == null) {
      setState(() {
        rutaInicial = AppRoutes.welcome;
      });
    } else {
      setState(() {
        rutaInicial = AppRoutes.home;
      });
    }
    print(rutaInicial);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: ColorsConstants.whiteColor),
    );

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
        AppRoutes.search: (context) => const Search(),
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.introduction: (context) => const Introduction(),
        AppRoutes.chooseAccount: (context) => const ChooseAccount(),
        AppRoutes.register: (context) => const Register(),
        AppRoutes.login: (context) => const Login(),
        AppRoutes.introductionDoctor: (context) => const IntroductionDoctor(),
        AppRoutes.postCommunity: (context) => const PostCommunity(),
        AppRoutes.postProTip: (context) => const PostProTip(),
      },
    );
  }
}
