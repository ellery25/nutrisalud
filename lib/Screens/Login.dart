import 'package:flutter/material.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../Helpers/HelpersExport.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Providers/UsersProviders.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> revisarCoincidencia() async {
    final usuarios = await Usuario.getUsuarios();

    bool usuarioEncontrado = false;

    // Imprimir el JSON de Usuarios
    print(usuarios);

    // Recorrer el JSON para buscar coincidencias
    for (var usuario in usuarios) {
      if (usuario.usuario == _emailController.text &&
          usuario.contrasena == _passwordController.text) {
        usuarioEncontrado = true;
        print('Usuario encontrado');
        break;
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
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.07),
            child: SvgPicture.asset(AssetsRoute.logoSvg,
                color: ColorsConstants.whiteColor,
                height: MediaQuery.of(context).size.height * 0.17),
          ),
          const SizedBox(height: 30),

          Expanded(
              child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    topLeft: Radius.circular(50)),
                color: ColorsConstants.whiteColor),
            width: MediaQuery.of(context).size.width * 1,
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
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                      labelText: 'Email:',
                      labelStyle: const TextStyle(color: Colors.green),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
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
                      if (coincidencia) {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
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
          ))
        ],
      )),
    );
  }
}
