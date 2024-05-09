import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';

class ProfessionalTipsBlock extends StatelessWidget {
  final String title;
  final String tip;
  final String nutricionistAvatar;

  const ProfessionalTipsBlock(
      {super.key,
      required this.title,
      required this.tip,
      required this.nutricionistAvatar});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(20),
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        border: Border.all(color: ColorsConstants.darkGreen),
        borderRadius: BorderRadius.circular(15),
        color: ColorsConstants.whiteColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ColorsConstants.darkGreen,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    tip,
                    softWrap: true,
                    style: const TextStyle(
                      color: ColorsConstants.darkGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -17),
                child: CircleAvatar(
                  backgroundImage: AssetImage(nutricionistAvatar),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}