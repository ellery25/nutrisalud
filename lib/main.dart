import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrisalud/Helpers/Colors.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/NutriSaludBtBar.dart';
import './Screens/Screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: ColorsConstants.whiteColor),
    );
    return MaterialApp(
      title: 'NutriSalud ',
      initialRoute: AppRoutes.home,
      onGenerateRoute: (routes) {
        switch (routes.name) {
          case AppRoutes.home:
            return MaterialPageRoute(
                builder: (context) => const NutriSaludBtBar());
          case AppRoutes.nutricionist:
            return MaterialPageRoute(
                builder: (context) => const Nutricionists());
          case AppRoutes.Search:
            return MaterialPageRoute(builder: (context) => const Search());
          case AppRoutes.welcome:
            return MaterialPageRoute(
                builder: (context) => const WelcomeScreen());
          case AppRoutes.introduction:
            return MaterialPageRoute(
                builder: (context) => const Introduction());
          case AppRoutes.chooseAcount:
            return MaterialPageRoute(
                builder: (context) => const ChooseAcount());
          case AppRoutes.register:
            return MaterialPageRoute(builder: (context) => Register());
          case AppRoutes.login:
            return MaterialPageRoute(builder: (context) => Login());
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
