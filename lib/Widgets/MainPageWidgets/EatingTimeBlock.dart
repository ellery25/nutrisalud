import 'package:flutter/material.dart';
import '../../Helpers/Colors.dart';

class EatingTimeBlock extends StatelessWidget {
  final String type;
  final String food;
  final String time;

  const EatingTimeBlock(
      {super.key, required this.type, required this.food, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: ColorsConstants.lightGreen,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: ColorsConstants.whiteColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 23),
                  child: Text(
                    food,
                    softWrap: true,
                    style: const TextStyle(
                      color: ColorsConstants.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -17),
                child: Container(
                  alignment: Alignment.topRight,
                  child: Text(
                    time,
                    style: const TextStyle(
                      color: ColorsConstants.whiteColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
