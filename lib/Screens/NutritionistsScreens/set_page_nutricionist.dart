// ignore: file_names
import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/app_routes.dart';
import 'package:nutrisalud/Helpers/colors_codes.dart';
import 'package:nutrisalud/Providers/nutritionists_providers.dart';

class SetPageNutricionist extends StatefulWidget {
  const SetPageNutricionist({super.key});

  @override
  _SetPageNutricionist createState() => _SetPageNutricionist();
}

class _SetPageNutricionist extends State<SetPageNutricionist> {
  // Opción seleccionada por defecto
  bool _isVisible = false;
  bool _isVisible2 = false;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _skill1Controller = TextEditingController();
  final TextEditingController _skill2Controller = TextEditingController();
  final TextEditingController _skill3Controller = TextEditingController();
  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void _toggleVisibility2() {
    setState(() {
      _isVisible2 = !_isVisible2;
    });
  }

  Future<bool> validarLogin() async {
    bool accesoConcedido;

    try {
      Map<String, dynamic> user = await Nutritionist.createNutricionist({
        'name': _nameController.text,
        'username': _userNameController.text,
        'password': _passwordController.text,
        'email': _emailController.text,
        'description': 'a',
        'rating': 'a',
        'photo': 'a',
        'instagram': 'a',
        'website': 'a',
        'whatsapp': 'a',
        'skill1': 'a',
        'skill2': 'a',
        'skill3': 'a',
      });

      if (user.containsKey('error')) {
        accesoConcedido = false;
      } else {
        accesoConcedido = true;
      }
    } catch (e) {
      print('Error al crear usuario: $e');
      accesoConcedido = false;
    }
    return accesoConcedido;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: ColorsConstants.whiteColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Register Nutricionist',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorsConstants.darkGreen),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '* required',
                    style: TextStyle(fontSize: 13),
                  ),

                  const SizedBox(height: 15),
                  const Text('Name *'),
                  TextFormField(
                    controller: _nameController,
                  ),
                  const SizedBox(height: 15),
                  const Text('Username *'),
                  TextFormField(
                    controller: _userNameController,
                  ),
                  const SizedBox(height: 15),
                  const Text('Password *'),
                  TextFormField(
                    controller: _passwordController,
                  ),

                  const SizedBox(height: 15),
                  const Text('Email: *'),
                  TextFormField(
                    controller: _emailController,
                  ),

                  const SizedBox(height: 15),
                  const Text('Social Media'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {
                          _toggleVisibility();
                        },
                      ),
                      const Text(
                        'Add social media',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  _isVisible ? _buildContainer() : const SizedBox(),
                  const SizedBox(height: 20),

                  const Text(
                      'Skills *'), // Construir el contenedor solo si es visible
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {
                          _toggleVisibility2();
                        },
                      ),
                      const Text(
                        'Add Skills',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  _isVisible2 ? _buildContainer2() : const SizedBox(),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
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
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                            'Loading Data',
                            style: TextStyle(color: ColorsConstants.whiteColor),
                          ),
                          duration: Duration(seconds: 1),
                          backgroundColor: ColorsConstants.darkGreen,
                        ));

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
                                    "The user or ig or wp or email is already in use",
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
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.3)),
                      child: const Text(
                        'Register',
                        style: TextStyle(color: ColorsConstants.whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer() {
    return Container(
      child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Website'),
            SizedBox(height: 10),
            Text('Instagram'),
            TextField(),
            SizedBox(height: 10),
            Text('Whatsapp'),
            TextField(),
          ]),
    );
  }

  Widget _buildContainer2() {
    return Container(
      child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Skill 1 *'),
            TextField(),
            SizedBox(height: 10),
            Text('Skill 2'),
            TextField(),
            SizedBox(height: 10),
            Text('Skill 3'),
            TextField(),
          ]),
    );
  }
}
