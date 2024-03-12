// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../Helpers/HelpersExport.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ColorsConstants.lightGreen,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              AppBar(
                backgroundColor: ColorsConstants.lightGreen,
                foregroundColor: ColorsConstants.whiteColor,
              ),
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: ColorsConstants.lightGreen,
                ),
                child: Center(
                  child: SvgPicture.asset(AssetsRoute.logoSvg,
                      color: ColorsConstants.whiteColor,
                      height: screenHeight * 0.17),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: ColorsConstants.whiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
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
                      const SizedBox(height: 40),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
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
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            //Crear post de registro de usuario
                            //Si todo está bien mandará a screen Introduction
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.introduction);
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.mail_outline),
                            onPressed: () {
                              // Acción para mail
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.loop),
                            onPressed: () {
                              // Acción para loop
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.biotech_rounded),
                            onPressed: () {
                              // Acción para Twitter
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                          height: 20), // Espacio adicional en el fondo
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
