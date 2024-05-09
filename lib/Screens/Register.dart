import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrisalud/Providers/users_providers.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<bool> validarLogin() async {
    bool accesoConcedido = false;

    // Validar que el userName no esté siendo usado
    List<Usuario> usuarios = await Usuario.getUsuarios();
    for (var usuario in usuarios) {
      if (usuario.usuario == _userNameController.text) {
        print('Usuario ya existe');
        return false;
      }
    }

    // Crear el usuario
    try {
      Map<String, dynamic> nuevoUsuario = {
        'nombre': _nameController.text,
        'usuario': _userNameController.text,
        'contrasena': _passwordController.text,
      };

      await Usuario.postUsuario(nuevoUsuario);
      print('Usuario creado');
      accesoConcedido = true;
    } catch (e) {
      print('Error al crear usuario: $e');
      accesoConcedido = false;
    }

    return accesoConcedido;
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
            // Logo
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.07),
              child: SvgPicture.asset(
                AssetsRoutes.logoSvg,
                color: ColorsConstants.whiteColor,
                height: screenHeight * 0.17,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    topLeft: Radius.circular(50),
                  ),
                  color: ColorsConstants.whiteColor,
                ),
                width: screenWidth * 1,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Register',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ColorsConstants.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          labelText: 'Name:',
                          labelStyle: const TextStyle(color: Colors.green),
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
                          labelText: 'Username:',
                          labelStyle: const TextStyle(color: Colors.green),
                        ),
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
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          // Aviso si el nombre esta vacio
                          if (_nameController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  title: const Text("The name is empty",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorsConstants.darkGreen,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ColorsConstants.darkGreen,
                                      ),
                                      child: const Text("Close",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: ColorsConstants.whiteColor,
                                          )),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          // Aviso si el usuario esta vacio
                          if (_userNameController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  title: const Text("The user name is empty",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorsConstants.darkGreen,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ColorsConstants.darkGreen,
                                      ),
                                      child: const Text("Close",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: ColorsConstants.whiteColor,
                                          )),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          // Aviso si la contraseña esta vacia
                          if (_passwordController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  title: const Text("The password is empty",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorsConstants.darkGreen,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ColorsConstants.darkGreen,
                                      ),
                                      child: const Text("Close",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: ColorsConstants.whiteColor,
                                          )),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          // Indicador de carga de registro
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                title: Text('Procesing data',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: ColorsConstants.darkGreen,
                                      fontWeight: FontWeight.bold,
                                    )),
                                content: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: ColorsConstants.darkGreen,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );

                          if (await validarLogin()) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.login);
                          } else {
                            if (!context.mounted) return;
                            Navigator.pop(context);

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  title: const Text(
                                      "The user name is already in use",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorsConstants.darkGreen,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ColorsConstants.darkGreen,
                                      ),
                                      child: const Text("Close",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: ColorsConstants.whiteColor,
                                          )),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
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
                          'Register',
                          style: TextStyle(color: ColorsConstants.whiteColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
