import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';

class CheckingProfile extends StatelessWidget {
  const CheckingProfile({super.key});

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        const NetworkImage('https://via.placeholder.com/150'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Yassed Matta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorsConstants.darkGreen,
                    ),
                  ),
                  const Text(
                    'Deportist Specialist',
                    style: TextStyle(fontSize: 15, color: Color(0xff747474)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: ColorsConstants.lightGreen,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
                          child: Text(
                            'About You',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorsConstants.whiteColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            'Lorem ipsum dolor sit amet consectetur adipiscing elit, faucibus magnis natoque magna diam nisl fringilla, suspendisse cubilia senectus sociis donec nisi viverra, vulputate bibendum.',
                            style: TextStyle(
                              fontSize: 18,
                              color: ColorsConstants.whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: ColorsConstants.whiteColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
                          child: Text(
                            'Your Skills:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorsConstants.darkGreen,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: ListView(
                            shrinkWrap: true,
                            children: const [
                              Row(
                                children: [
                                  Icon(Icons.check,
                                      color: ColorsConstants.darkGreen,
                                      size: 20),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: ColorsConstants.darkGreen),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.check,
                                      color: ColorsConstants.darkGreen,
                                      size: 20),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: ColorsConstants.darkGreen),
                                    ),
                                  ),
                                ],
                              ),

                              // Agrega más habilidades aquí si es necesario
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 200,
                  ), // Espacio adicional al final para hacer scroll
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
