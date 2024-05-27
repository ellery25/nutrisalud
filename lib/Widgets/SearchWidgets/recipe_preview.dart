import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';

class RecipePreview extends StatelessWidget {
  final String idmeal;
  final String nameRecipe;
  final String imageRecipe;
  final String category;
  final String area;
  final VoidCallback onTap;

  const RecipePreview(
      {super.key,
      required this.idmeal,
      required this.nameRecipe,
      required this.imageRecipe,
      required this.category,
      required this.area,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: height * 0.02, horizontal: width * 0.12),
        alignment: Alignment.center,
        width: width * 0.8,
        padding: EdgeInsets.symmetric(
            vertical: height * 0.02, horizontal: width * 0.03),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: ColorsConstants.darkGreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.01),
            Container(
              alignment: Alignment.center,
              child: Text(
                nameRecipe,
                style: const TextStyle(
                    color: ColorsConstants.whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: height * 0.01),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              clipBehavior: Clip.hardEdge,
              child: Opacity(
                opacity: 0.7,
                child: Image.network(imageRecipe,
                    height: 280, fit: BoxFit.fitWidth)),
            ),
            SizedBox(height: height * 0.015),
            Text("$area Food",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: ColorsConstants.whiteColor)),
            SizedBox(height: height * 0.01),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  const TextSpan(
                      text: 'Category: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: ColorsConstants.whiteColor)),
                  TextSpan(
                      text: category,
                      style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: ColorsConstants.whiteColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
