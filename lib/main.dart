import 'package:flutter/material.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/NutriSaludBtBar.dart';
import './Screens/Screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriSalud',
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: (routes) {
        switch(routes.name) {
          case AppRoutes.home:
            return MaterialPageRoute(builder: (context) => const NutriSaludBtBar());
          case AppRoutes.nutricionist:
            return MaterialPageRoute(builder: (context) => const Nutricionists());
          case AppRoutes.Search:
            return MaterialPageRoute(builder: (context) => const Search());
          case AppRoutes.welcome:
            return MaterialPageRoute(builder: (context) => const WelcomeScreen());
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}