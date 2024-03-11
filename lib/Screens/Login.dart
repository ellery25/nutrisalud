import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/HelpersExport.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xff6BA368),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Color(0xff6BA368),
                  ),
                  child: Center(
                    child: SvgPicture.asset(AssetsRoute.logoSvg,
                        color: ColorsConstants.whiteColor,
                        height: MediaQuery.of(context).size.height * 0.17),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(height: 30),
                        Text(
                          'Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff527450),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            labelText: 'Email:',
                            labelStyle: TextStyle(color: Colors.green),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            labelText: 'Password:',
                            labelStyle: TextStyle(color: Colors.green),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Forgot your password?',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {}
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(color: ColorsConstants.whiteColor),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: ColorsConstants.darkGreen,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.mail_outline),
                              onPressed: () {
                                // Acción para mail
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.loop),
                              onPressed: () {
                                // Acción para loop
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.biotech_rounded),
                              onPressed: () {
                                // Acción para Twitter
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20), // Espacio adicional en el fondo
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
