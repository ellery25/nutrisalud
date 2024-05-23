// ignore_for_file: use_build_context_synchronously

import 'package:nutrisalud/Preferences/save_load.dart';
import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:nutrisalud/Providers/users_providers.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: ColorsConstants.lightGreen,
        body: SingleChildScrollView(
          child: Column(
            children: [
              AppBar(
                backgroundColor: ColorsConstants.lightGreen,
                foregroundColor: ColorsConstants.whiteColor,
              ),
              //Logo
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.07),
                child: SvgPicture.asset(AssetsRoutes.logoSvg,
                    color: ColorsConstants.whiteColor,
                    height: screenHeight * 0.17),
              ),
              const SizedBox(height: 30),
              Container(
                height: screenHeight * 0.616,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                        topLeft: Radius.circular(50)),
                    color: ColorsConstants.whiteColor),
                width: screenWidth * 1,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      const Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ColorsConstants.darkGreen,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.055),
                      TextFormField(
                        controller: _userNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                                color: ColorsConstants.darkGreen),
                          ),
                          labelText: 'Username:',
                          labelStyle:
                              const TextStyle(color: ColorsConstants.darkGreen),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your user name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                                color: ColorsConstants.darkGreen),
                          ),
                          labelText: 'Password:',
                          labelStyle:
                              const TextStyle(color: ColorsConstants.darkGreen),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          // Indicardor de carga de Login

                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              'Loading Data',
                              style:
                                  TextStyle(color: ColorsConstants.whiteColor),
                            ),
                            duration: Duration(seconds: 1),
                            backgroundColor: ColorsConstants.darkGreen,
                          ));

                          try {
                            await User.login(_userNameController.text,
                                _passwordController.text);
                            String isFirstTime =
                                await SharedPreferencesHelper.loadData(
                                        "isFirstTime") ??
                                    "true";
                            String? userType =
                                await SharedPreferencesHelper.loadData("type");
                            if (userType == "user") {
                              await SharedPreferencesHelper.saveData(
                                  'username', _userNameController.text);
                              if (isFirstTime == "true") {
                                await SharedPreferencesHelper.saveData(
                                    "isFirstTime", "false");
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.introduction);
                              } else if (isFirstTime == "false") {
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.home);
                              } else {
                                throw Exception("Failed to load isFirstTime");
                              }
                            } else if (userType == "nutritionist") {
                              await SharedPreferencesHelper.saveData(
                                  'username', _userNameController.text);
                              if (isFirstTime == "true") {
                                await SharedPreferencesHelper.saveData(
                                    "isFirstTime", "false");
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.introductionDoctor);
                              } else if (isFirstTime == "false") {
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.home);
                              } else {
                                throw Exception("Failed to load isFirstTime");
                              }
                            } else {
                              throw Exception("User type not found");
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to login')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsConstants.darkGreen,
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.2)),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              color: ColorsConstants.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
