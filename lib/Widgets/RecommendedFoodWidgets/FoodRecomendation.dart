// ignore: file_names
import 'package:flutter/material.dart';
import '../../Helpers/Colors.dart';

class FoodRecomendation extends StatelessWidget {
  final String titulo;
  final String timeToEat;
  final String descripcion;

  const FoodRecomendation(
      {super.key,
      required this.titulo,
      required this.timeToEat,
      required this.descripcion});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
          border: Border.all(color: ColorsConstants.darkGreen),
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
                      color: ColorsConstants.darkGreen,
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
                      color: ColorsConstants.darkGreen,
                    ),
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: ColorsConstants.darkGreen,
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
