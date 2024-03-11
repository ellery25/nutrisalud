import 'package:flutter/material.dart';
import '../Helpers/HelpersExport.dart';

class SetPageNutricionist extends StatefulWidget {
  const SetPageNutricionist({Key? key}) : super(key: key);

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
                  Text(
                    'Contact Info:',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorsConstants.darkGreen),
                  ),
                  SizedBox(height: 20),
                  Text('Profile URL:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'www.nutrisalud.com/in/drbayter',
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SetPageNutricionist()),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Email:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'drbayter@gmail.com',
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SetPageNutricionist()),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Phone Number'),
                  TextField(),
                  SizedBox(height: 20),
                  Text('Address'),
                  TextField(),
                  SizedBox(height: 20),
                  Text('Birthday'),
                  TextField(),
                  SizedBox(height: 20),
                  Text('WebSite'),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.more_horiz),
                        onPressed: () {
                          _toggleVisibility();
                        },
                      ),
                      Text(
                        'Add website',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  _isVisible ? _buildContainer() : SizedBox(),
                  SizedBox(height: 20),

                  Text(
                      'Instant Messaging'), // Construir el contenedor solo si es visible
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.more_horiz),
                        onPressed: () {
                          _toggleVisibility2();
                        },
                      ),
                      Text(
                        'Add messaging option',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  _isVisible2 ? _buildContainer2() : SizedBox(),

                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción cuando se presiona el botón "Next"
                      },
                      child: Text('Next'),
                      style: ElevatedButton.styleFrom(
                        primary:
                            ColorsConstants.lightGreen, // Color de fondo blanco
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Website'),
        TextField(),
      ]),
    );
  }

  Widget _buildContainer2() {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Username'),
        TextField(),
      ]),
    );
  }
}
