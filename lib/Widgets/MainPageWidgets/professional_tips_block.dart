import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';

class ProfessionalTipsBlock extends StatelessWidget {
  final String photo;
  final String? title;
  final String? tip;

  const ProfessionalTipsBlock(
      {super.key, this.title, this.tip, required this.photo});

  Map<String, dynamic> toJson() => {
        'title': title,
        'tip': tip,
        'photo': photo,
      };

  factory ProfessionalTipsBlock.fromJson(Map<String, dynamic> json) {
    return ProfessionalTipsBlock(
      title: json['title'],
      tip: json['tip'],
      photo: json['photo'],
    );
  }

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
            title.toString(),
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
                    tip.toString(),
                    softWrap: true,
                    style: const TextStyle(
                      color: ColorsConstants.darkGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(photo),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
