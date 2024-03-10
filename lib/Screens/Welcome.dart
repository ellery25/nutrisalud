import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import '../Helpers/HelpersExport.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff6BA368),
      body: SafeArea(
          child: Column(
        children: [
          //Logo
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.07),
            child: SvgPicture.asset(AssetsRoute.logoSvg,
                color: ColorsConstants.whiteColor,
                height: MediaQuery.of(context).size.height * 0.17),
          ),

          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01,
                  bottom: MediaQuery.of(context).size.height * 0.05),
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
            width: MediaQuery.of(context).size.width * 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Welcome!
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.05),
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
                  onTap: () {},
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color(0xff527450),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: MediaQuery.of(context).size.height * 0.07,
                    alignment: Alignment.center,
                    child: const Text('Login',
                        style: TextStyle(
                            color: ColorsConstants.whiteColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                //Register
                InkWell(
                  onTap: () {},
                  child: Container(
                    decoration: const BoxDecoration(
                        color: ColorsConstants.darkGreen,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: MediaQuery.of(context).size.height * 0.07,
                    alignment: Alignment.center,
                    child: const Text('Register',
                        style: TextStyle(
                            color: Color(0xffF5F5F5),
                            fontSize: 24,
                            fontWeight: FontWeight.w700)),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                //Or continue with
                Row(
                  children: [
                    Container(
                      color: const Color(0xff527450),
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.03),
                      width: MediaQuery.of(context).size.width * 0.32,
                      height: MediaQuery.of(context).size.height * 0.002,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Or continue with',
                        style:
                            TextStyle(color: Color(0xff527450), fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: const Color(0xff527450),
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.03),
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * 0.002,
                      ),
                    )
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                //Accounts
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(AssetsRoute.gmailSvg,
                          color: ColorsConstants.darkGreen,
                          height: MediaQuery.of(context).size.height * 0.04),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.07),
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(AssetsRoute.metaSvg,
                          color: ColorsConstants.darkGreen,
                          height: MediaQuery.of(context).size.height * 0.04),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.07),
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(AssetsRoute.twitterSvg,
                          color: ColorsConstants.darkGreen,
                          height: MediaQuery.of(context).size.height * 0.04),
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
