import 'package:flutter/material.dart';

class ProfessionalTipsBlock extends StatelessWidget {
  final String title;
  final String tip;
  final String nutricionistAvatar;

  ProfessionalTipsBlock(
      {required this.title,
      required this.tip,
      required this.nutricionistAvatar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff527450)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff527450),
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
                      color: Color(0xff527450),
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
