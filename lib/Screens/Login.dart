import 'package:nutrisalud/Preferences/save_load.dart';
import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrisalud/Providers/users_providers.dart';
import 'package:nutrisalud/Providers/nutricionists_providers.dart';

// TODO: Indicador de carga mientras se procesa la peticion de Login

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

  Future<bool> revisarCoincidencia() async {
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
        await SharedPreferencesHelper.saveData('userId', usuario.id.toString());

        print('Usuario encontrado, id: ${usuario.id}');
        // Guardar la variable de isNutricionist false en shared preference

        await SharedPreferencesHelper.saveData('isNutricionist', "false");

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
          await SharedPreferencesHelper.saveData(
              'userId', nutricionista.id.toString());
          print('Nutricionista encontrado, id: ${nutricionista.id}');
          // Guardar la variable de isNutricionist true en shared preference
          await SharedPreferencesHelper.saveData('isNutricionist', "true");

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
      body: SafeArea(
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
                color: ColorsConstants.whiteColor, height: screenHeight * 0.17),
          ),
          const SizedBox(height: 30),

          Expanded(
              child: Container(
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      // Carga del Login
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Procesing data'),
                            content: Container(
                              height: 50,
                              width: 50,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        },
                      );
                      // Carga del Login
                      bool coincidencia = await revisarCoincidencia();
                      String isFirstTime =
                          await SharedPreferencesHelper.loadData(
                                  "isFirstTime") ??
                              "true";
                      if (coincidencia) {
                        if (isFirstTime == "true") {
                          await SharedPreferencesHelper.saveData(
                              "isFirstTime", "false");
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.introduction);
                        } else {
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.home);
                        }
                      } else {
                        if (!context.mounted) return;
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
          ))
        ],
      )),
    );
  }
}
