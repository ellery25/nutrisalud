// ignore: file_names
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:nutrisalud/Providers/NutricionistsProviders.dart';
import 'package:nutrisalud/Providers/Preferences/FirsTime.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../Helpers/HelpersExport.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Providers/UsersProviders.dart';
import '../Providers/Preferences/UsuarioPreferences.dart';
import '../Providers/Preferences/IsNutricionist.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
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

  Future<bool> revisarCoincidencia() async {
    // Instancias del shared preference
    UserPersistence userPersistence = await UserPersistence.getInstance();
    IsNutricionist isNutricionistCheck = await IsNutricionist.getInstance();

    // Variable para saber si el usuario fue encontrado
    bool usuarioEncontrado = false;

    // Get de usuarios
    final usuarios = await Usuario.getUsuarios();

    // Recorrer el JSON para buscar coincidencias
    for (var usuario in usuarios) {
      if (usuario.usuario == _userNameController.text &&
          usuario.contrasena == _passwordController.text) {
        usuarioEncontrado = true;
        // Guardar la variable en shared preference
        await userPersistence.saveUser('userId', usuario.id.toString());
        print('Usuario encontrado, id: ${usuario.id}');
        // Guardar la variable de isNutricionist false en shared preference
        await isNutricionistCheck.saveIsNutricionist('isNutricionist?', false);
        break;
      }
    }

    // Validar coincidencia en la coleccion de nutricionistas si no fue encontrado en usuarios
    if (!usuarioEncontrado) {
      final nutricionistas = await Nutricionistas.getNutricionistas();
      for (var nutricionista in nutricionistas) {
        if (nutricionista.email == _userNameController.text &&
            nutricionista.contrasena == _passwordController.text) {
          usuarioEncontrado = true;
          // Guardar la variable en shared preference
          await userPersistence.saveUser('userId', nutricionista.id.toString());
          print('Nutricionista encontrado, id: ${nutricionista.id}');
          // Guardar la variable de isNutricionist true en shared preference
          await isNutricionistCheck.saveIsNutricionist('isNutricionist?', true);
          break;
        }
      }
    }
    return usuarioEncontrado;
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
                child: SvgPicture.asset(AssetsRoute.logoSvg,
                    color: ColorsConstants.whiteColor,
                    height: screenHeight * 0.17),
              ),
              const SizedBox(height: 30),

              Container(
                height: screenHeight * 0.62,
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
                      const SizedBox(height: 30),
                      const Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ColorsConstants.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _userNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          labelText: 'Nombre de usuario:',
                          labelStyle: const TextStyle(color: Colors.green),
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
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          labelText: 'Password:',
                          labelStyle: const TextStyle(color: Colors.green),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Forgot your password?',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          bool coincidencia = await revisarCoincidencia();
                          bool isFirstTime =
                              await FirsTimePreferences.isFirstTime() ?? true;
                          if (coincidencia) {
                            if (isFirstTime) {
                              await FirsTimePreferences.setFirstTime(false);
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.introduction);
                            } else {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.home);
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'Usuario o contraseña incorrectos'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Aceptar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsConstants.darkGreen,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(color: ColorsConstants.whiteColor),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
      )
    );
  }
}
