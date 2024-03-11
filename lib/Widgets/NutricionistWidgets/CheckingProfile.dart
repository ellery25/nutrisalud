import 'package:flutter/material.dart';

class CheckingProfile extends StatelessWidget {
  const CheckingProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xffF5F5F5),
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
                        NetworkImage('https://via.placeholder.com/150'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Yassed Matta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff527450),
                    ),
                  ),
                  Text(
                    'Deportist Specialist',
                    style: TextStyle(fontSize: 15, color: Color(0xff747474)),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xff6BA368),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
                          child: Text(
                            'About You',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffF5F5F5),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            'Lorem ipsum dolor sit amet consectetur adipiscing elit, faucibus magnis natoque magna diam nisl fringilla, suspendisse cubilia senectus sociis donec nisi viverra, vulputate bibendum.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xffF5F5F5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
                          child: Text(
                            'Your Skills:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff527450),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check,
                                      color: Color(0xff527450), size: 20),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xff527450)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.check,
                                      color: Color(0xff527450), size: 20),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xff527450)),
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
                  SizedBox(
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
