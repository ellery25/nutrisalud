// ignore: file_names
import 'package:flutter/material.dart';
import '../../Helpers/Colors.dart';

class CommunityPost extends StatelessWidget {
  final String contenido;
  final String? foto;
  final int horas;
  final String nombre;
  final String username;

  const CommunityPost(
      {super.key,
      this.foto,
      required this.horas,
      required this.contenido,
      required this.username,
      required this.nombre});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
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
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: ColorsConstants.darkGreen,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '@$username',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                        color: ColorsConstants.darkGreen,
                      ),
                    ),
                    const Spacer(),
                    const Spacer(),
                    Text(
                      '${horas}h',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                        color: ColorsConstants.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                contenido,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: ColorsConstants.darkGreen,
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
                      border: Border.all(color: ColorsConstants.darkGreen),
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
