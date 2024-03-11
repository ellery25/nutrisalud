import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrisalud/Helpers/HelpersExport.dart';
import 'package:flutter/services.dart';

class ChooseAcount extends StatefulWidget {
  const ChooseAcount({super.key});

  @override
  State<ChooseAcount> createState() => _ChooseAcountState();
}

class _ChooseAcountState extends State<ChooseAcount> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light
          .copyWith(statusBarColor: ColorsConstants.lightGreen),
    );
    return Scaffold(
        backgroundColor: ColorsConstants.lightGreen,
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.07,
              vertical: MediaQuery.of(context).size.height * 0.07),
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
                height: MediaQuery.of(context).size.height * 0.03,
              ),

              // Nutricionist
              InkWell(
                onTap: () {},
                splashColor: MaterialStateColor.resolveWith((states) => ColorsConstants.darkGreen),
                customBorder: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: const BoxDecoration(
                      color: ColorsConstants.whiteColor,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.08),
                        child: SvgPicture.asset(AssetsRoute.logoSvg, color: ColorsConstants.darkGreen, height: MediaQuery.of(context).size.height * 0.15),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                      const Text('Nutricionist', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400, color: ColorsConstants.darkGreen),)
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
              ),

              // Client
              InkWell(
                onTap: () {

                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: const BoxDecoration(
                      color: ColorsConstants.whiteColor,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.07),
                        child: Icon(Icons.account_circle_outlined, size: MediaQuery.of(context).size.height * 0.15, color: ColorsConstants.darkGreen),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                      const Text('User', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400, color: ColorsConstants.darkGreen),)
                    ],
                  ),
                ),
              ),

            ],
          ),
        ));
  }
}
