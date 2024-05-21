import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:flutter/services.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light
          .copyWith(statusBarColor: ColorsConstants.lightGreen),
    );
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ColorsConstants.lightGreen,
      body: SafeArea(
          child: Column(
        children: [
          //Logo
          Container(
            margin: EdgeInsets.only(top: screenHeight * 0.07),
            child: SvgPicture.asset(AssetsRoutes.logoSvg,
                color: ColorsConstants.whiteColor, height: screenHeight * 0.17),
          ),

          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                  top: screenHeight * 0.01, bottom: screenHeight * 0.05),
              child: const Text(
                "NutriSalud",
                style: TextStyle(
                    color: ColorsConstants.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              )),

          //Forms
          Expanded(
              child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    topLeft: Radius.circular(50)),
                color: ColorsConstants.whiteColor),
            width: screenWidth * 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // Welcome!
                const Text(
                  'Welcome!',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: ColorsConstants.darkGreen),
                ),

                SizedBox(height: screenHeight * 0.05),

                //Login
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        color: ColorsConstants.darkGreen,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    width: screenWidth * 0.65,
                    height: screenHeight * 0.07,
                    alignment: Alignment.center,
                    child: const Text('Login',
                        style: TextStyle(
                            color: ColorsConstants.whiteColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700)),
                  ),
                ),

                SizedBox(height: screenHeight * 0.06),

                //Register
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.chooseAccount);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        color: ColorsConstants.darkGreen,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    width: screenWidth * 0.65,
                    height: screenHeight * 0.07,
                    alignment: Alignment.center,
                    child: const Text('Register',
                        style: TextStyle(
                            color: ColorsConstants.whiteColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700)),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ))
        ],
      )),
    );
  }
}
