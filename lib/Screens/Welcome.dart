import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../Helpers/HelpersExport.dart';
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
            child: SvgPicture.asset(AssetsRoute.logoSvg,
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
                // Welcome!
                Container(
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                  child: const Text(
                    'Welcome!',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: ColorsConstants.darkGreen),
                  ),
                ),

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
                    Navigator.pushNamed(context, AppRoutes.chooseAcount);
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

                SizedBox(height: screenHeight * 0.08),

                //Or continue with
                Row(
                  children: [
                    Container(
                      color: ColorsConstants.darkGreen,
                      margin: EdgeInsets.only(right: screenWidth * 0.03),
                      width: screenWidth * 0.32,
                      height: screenHeight * 0.002,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Or continue with',
                        style: TextStyle(
                            color: ColorsConstants.darkGreen, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: ColorsConstants.darkGreen,
                        margin: EdgeInsets.only(left: screenWidth * 0.03),
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.002,
                      ),
                    )
                  ],
                ),

                SizedBox(height: screenHeight * 0.04),

                //Accounts
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(AssetsRoute.gmailSvg,
                          color: ColorsConstants.darkGreen,
                          height: screenHeight * 0.04),
                    ),
                    SizedBox(width: screenWidth * 0.07),
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(AssetsRoute.metaSvg,
                          color: ColorsConstants.darkGreen,
                          height: screenHeight * 0.04),
                    ),
                    SizedBox(width: screenWidth * 0.07),
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(AssetsRoute.twitterSvg,
                          color: ColorsConstants.darkGreen,
                          height: screenHeight * 0.04),
                    )
                  ],
                ),
              ],
            ),
          ))
        ],
      )),
    );
  }
}
