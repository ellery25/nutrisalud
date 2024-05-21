import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:flutter/services.dart';

class ChooseAccount extends StatefulWidget {
  const ChooseAccount({super.key});

  @override
  State<ChooseAccount> createState() => _ChooseAccountState();
}

class _ChooseAccountState extends State<ChooseAccount> {
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
        appBar: AppBar(
          backgroundColor: ColorsConstants.lightGreen,
          foregroundColor: ColorsConstants.whiteColor,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.07, vertical: screenHeight * 0.001),
          child: Column(
            children: [
              //Are you a:
              Container(
                alignment: Alignment.centerLeft,
                child: const Text('Are you a:',
                    style: TextStyle(
                        color: ColorsConstants.whiteColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),

              // Nutricionist
              InkWell(
                onTap: () {
                  //Definir tipo de cuenta
                  Navigator.popAndPushNamed(
                      context, AppRoutes.setPageNutricionist);
                },
                splashColor: MaterialStateColor.resolveWith(
                    (states) => ColorsConstants.darkGreen),
                customBorder: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Container(
                  height: screenHeight * 0.35,
                  width: screenWidth * 0.85,
                  decoration: const BoxDecoration(
                      color: ColorsConstants.whiteColor,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: screenHeight * 0.08),
                        child: SvgPicture.asset(AssetsRoutes.logoSvg,
                            color: ColorsConstants.darkGreen,
                            height: screenHeight * 0.15),
                      ),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
                      const Text(
                        'Nutricionist',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                            color: ColorsConstants.darkGreen),
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: screenHeight * 0.07,
              ),

              // Client
              InkWell(
                onTap: () {
                  //Definir tipo de cuenta
                  Navigator.popAndPushNamed(context, AppRoutes.register);
                },
                child: Container(
                  height: screenHeight * 0.35,
                  width: screenWidth * 0.85,
                  decoration: const BoxDecoration(
                      color: ColorsConstants.whiteColor,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: screenHeight * 0.07),
                        child: Icon(Icons.account_circle_outlined,
                            size: screenHeight * 0.15,
                            color: ColorsConstants.darkGreen),
                      ),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
                      const Text(
                        'User',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                            color: ColorsConstants.darkGreen),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
