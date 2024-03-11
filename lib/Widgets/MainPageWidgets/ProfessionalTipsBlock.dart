import 'package:flutter/material.dart';
import '../../Helpers/Colors.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        border: Border.all(color: ColorsConstants.darkGreen),
        borderRadius: BorderRadius.circular(15),
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
