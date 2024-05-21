// ignore: file_names
import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/colors_codes.dart';

class SetPageNutricionist extends StatefulWidget {
  const SetPageNutricionist({super.key});

  @override
  _SetPageNutricionist createState() => _SetPageNutricionist();
}

class _SetPageNutricionist extends State<SetPageNutricionist> {
  // Opción seleccionada por defecto
  bool _isVisible = false;
  bool _isVisible2 = false;

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
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
                    'Contact Info:',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorsConstants.darkGreen),
                  ),
                  const SizedBox(height: 20),
                  const Text('Profile URL:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'www.nutrisalud.com/in/drbayter',
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SetPageNutricionist()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Email:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'drbayter@gmail.com',
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SetPageNutricionist()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Phone Number'),
                  const TextField(),
                  const SizedBox(height: 20),
                  const Text('Address'),
                  const TextField(),
                  const SizedBox(height: 20),
                  const Text('Birthday'),
                  const TextField(),
                  const SizedBox(height: 20),
                  const Text('WebSite'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {
                          _toggleVisibility();
                        },
                      ),
                      const Text(
                        'Add website',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  _isVisible ? _buildContainer() : const SizedBox(),
                  const SizedBox(height: 20),

                  const Text(
                      'Instant Messaging'), // Construir el contenedor solo si es visible
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {
                          _toggleVisibility2();
                        },
                      ),
                      const Text(
                        'Add messaging option',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  _isVisible2 ? _buildContainer2() : const SizedBox(),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción cuando se presiona el botón "Next"
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            ColorsConstants.lightGreen, // Color de fondo blanco
                      ),
                      child: const Text('Next'),
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
            TextField(),
          ]),
    );
  }

  Widget _buildContainer2() {
    return Container(
      child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Username'),
            TextField(),
          ]),
    );
  }
}
