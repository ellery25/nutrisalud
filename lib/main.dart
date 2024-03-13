import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrisalud/Screens/PostProTip.dart';
import '../Helpers/HelpersExport.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/NutriSaludBtBar.dart';
import './Screens/Screens.dart';
import './Providers/Preferences/UsuarioPreferences.dart';

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

    Future<String> _defineInitialRoute() async {
      UserPersistence userPersistence = await UserPersistence.getInstance();

      String userId = userPersistence.getUser('userId');

      return userId.isNotEmpty ? AppRoutes.home : AppRoutes.welcome;
    }

    return FutureBuilder<String>(
      future: _defineInitialRoute(),
      builder: (context, snapshot) {
         if(snapshot.connectionState == ConnectionState.done){
           return MaterialApp(
             title: 'NutriSalud ',
             initialRoute: AppRoutes.welcome,
             onGenerateRoute: (routes) {
               switch (routes.name) {
                 case AppRoutes.home:
                   return MaterialPageRoute(
                       builder: (context) => const NutriSaludBtBar());
                 case AppRoutes.nutricionist:
                   return MaterialPageRoute(
                       builder: (context) => const Nutricionists());
                 case AppRoutes.search:
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
                   return MaterialPageRoute(builder: (context) => const Register());
                 case AppRoutes.login:
                   return MaterialPageRoute(builder: (context) => const Login());
                 case AppRoutes.introductionDoctor:
                   return MaterialPageRoute(
                       builder: (context) => const IntroductionDoctor());
                 case AppRoutes.postCommunity:
                   return MaterialPageRoute(builder: (context) => const PostCommunity());
                 case AppRoutes.postProTip:
                   return MaterialPageRoute(builder: (context) => const PostProTip());
               }
               return null;
             },
             debugShowCheckedModeBanner: false,
           );
         } else {
           return CircularProgressIndicator();
         }
      },
    );
  }
}
