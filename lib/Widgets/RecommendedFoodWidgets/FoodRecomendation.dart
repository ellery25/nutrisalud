import 'package:flutter/material.dart';

class FoodRecomendation extends StatelessWidget {
  final String titulo;
  final String timeToEat;
  final String descripcion;

  FoodRecomendation(
      {required this.titulo,
      required this.timeToEat,
      required this.descripcion});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
          border: Border.all(color: Color(0xff527450)),
        ),

        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff527450),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    'Best time to eat: $timeToEat',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff527450),
                    ),
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff527450),
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
