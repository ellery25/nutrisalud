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
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: height * 0.02, horizontal: width * 0.12),
      alignment: Alignment.center,
      width: width * 0.8,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: ColorsConstants.lightGreen),
      child: Column(
        children: [
          Container(
            width: width * 0.8,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.network(imageRecipe, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              nameRecipe,
              style: const TextStyle(
                color: ColorsConstants.whiteColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Origin: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: ColorsConstants.whiteColor,
                      ),
                    ),
                    Text(
                      area,
                      style: const TextStyle(
                        fontSize: 20,
                        color: ColorsConstants.whiteColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Category: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: ColorsConstants.whiteColor,
                      ),
                    ),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 20,
                        color: ColorsConstants.whiteColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              width: (width * 0.8) - 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: ColorsConstants.whiteColor),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Details ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: ColorsConstants.darkGreen,
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        color: ColorsConstants.darkGreen,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
