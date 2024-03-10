import 'package:flutter/material.dart';

class CommunityPost extends StatelessWidget {
  final String contenido;
  final String? foto;
  final int horas;
  final String nombre;
  final String username;

  CommunityPost(
      {this.foto,
      required this.horas,
      required this.contenido,
      required this.username,
      required this.nombre});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 2.0, color: Color(0xffE3E3E3)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      nombre,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff527450),
                      ),
                    ),
                    Spacer(),
                    Text(
                      '@$username',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff527450),
                      ),
                    ),
                    Spacer(),
                    Spacer(),
                    Text(
                      horas.toString() + 'h',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff527450),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                contenido,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff527450),
                ),
              ),
              if (foto != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    width: screenWidth * 0.80,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                      border: Border.all(color: Color(0xff527450)),
                    ),
                    child: Center(
                      child: Image.asset(foto!),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
