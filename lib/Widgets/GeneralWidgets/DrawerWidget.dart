// ignore: file_names
import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/HelpersExport.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../../Providers/Preferences/UsuarioPreferences.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    BuildContext currentContext = context;
    return Drawer(
        backgroundColor: ColorsConstants.whiteColor,
        child: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.1),
          child: Column(
            children: [
              CircleAvatar(radius: screenHeight * 0.1),
              SizedBox(height: screenHeight * 0.02),

              //Aquí va el nombre del usuario
              const Text('Ellery Ricaurte',
                  style: TextStyle(
                      color: ColorsConstants.darkGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),

              //Aquí va el correo del usuario
              const Text('elleryrica12@gmail.com',
                  style: TextStyle(
                      color: ColorsConstants.darkGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic)),

              SizedBox(height: screenHeight * 0.25),

              //Help, conditions and Share
              Container(
                width: screenWidth * 0.9,
                margin: EdgeInsets.only(right: screenWidth * 0.15),
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => ColorsConstants.whiteColor),
                          shadowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent)),
                      child: Row(
                        children: [
                          const Text('Help',
                              style: TextStyle(
                                  color: ColorsConstants.darkGreen,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300)),
                          SizedBox(width: screenWidth * 0.03),
                          const Icon(
                            Icons.help_outline,
                            color: ColorsConstants.darkGreen,
                            weight: 1,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => ColorsConstants.whiteColor),
                          shadowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent)),
                      child: Row(
                        children: [
                          const Text('Terms & Conditions',
                              style: TextStyle(
                                  color: ColorsConstants.darkGreen,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300)),
                          SizedBox(width: screenWidth * 0.03),
                          const Icon(
                            Icons.menu_book,
                            color: ColorsConstants.darkGreen,
                            weight: 1,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => ColorsConstants.whiteColor),
                          shadowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent)),
                      child: Row(
                        children: [
                          const Text('Share with friends',
                              style: TextStyle(
                                  color: ColorsConstants.darkGreen,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300)),
                          SizedBox(width: screenWidth * 0.03),
                          const Icon(
                            Icons.share,
                            color: ColorsConstants.darkGreen,
                            weight: 1,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(
                          left: screenWidth * 0.5, bottom: screenHeight * 0.01),
                      alignment: Alignment.bottomRight,
                      child: Row(
                        children: [
                          const Text('Log out',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: ColorsConstants.darkGreen)),
                          IconButton(
                              onPressed: () async {
                                UserPersistence userPersistence = await UserPersistence.getInstance();
                                await userPersistence.setUser('userId', '');
                                Navigator.pushReplacementNamed(currentContext, AppRoutes.welcome);
                              },
                              icon: const Icon(
                                Icons.logout,
                                color: ColorsConstants.darkGreen,
                              ))
                        ],
                      )))
            ],
          ),
        ));
  }
}
