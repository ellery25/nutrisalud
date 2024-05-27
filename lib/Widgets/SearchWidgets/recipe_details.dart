import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';

class RecipeDetails extends StatefulWidget {

  final String idmeal;
  final String nameRecipe;
  final String imageRecipe;
  final String category;
  final String area;
  final String instructions;
  final String? ingredient1;
  final String? ingredient2;
  final String? ingredient3;
  final String? ingredient4;
  final String? ingredient5;
  final String? ingredient6;
  final String? ingredient7;
  final String? ingredient8;
  final String? ingredient9;
  final String? ingredient10;
  final String? ingredient11;
  final String? ingredient12;
  final String? ingredient13;
  final String? ingredient14;
  final String? ingredient15;
  final String? ingredient16;
  final String? ingredient17;
  final String? ingredient18;
  final String? ingredient19;
  final String? ingredient20;
  final String? measure1;
  final String? measure2;
  final String? measure3;
  final String? measure4;
  final String? measure5;
  final String? measure6;
  final String? measure7;
  final String? measure8;
  final String? measure9;
  final String? measure10;
  final String? measure11;
  final String? measure12;
  final String? measure13;
  final String? measure14;
  final String? measure15;
  final String? measure16;
  final String? measure17;
  final String? measure18;
  final String? measure19;
  final String? measure20;
  final String? youtube;

  const RecipeDetails({
      super.key,
      required this.idmeal,
      required this.nameRecipe,
      required this.imageRecipe,
      required this.category,
      required this.area,
      required this.instructions,
      this.ingredient1,
      this.ingredient2,
      this.ingredient3,
      this.ingredient4,
      this.ingredient5,
      this.ingredient6,
      this.ingredient7,
      this.ingredient8,
      this.ingredient9,
      this.ingredient10,
      this.ingredient11,
      this.ingredient12,
      this.ingredient13,
      this.ingredient14,
      this.ingredient15,
      this.ingredient16,
      this.ingredient17,
      this.ingredient18,
      this.ingredient19,
      this.ingredient20,
      this.measure1,
      this.measure2,
      this.measure3,
      this.measure4,
      this.measure5,
      this.measure6,
      this.measure7,
      this.measure8,
      this.measure9,
      this.measure10,
      this.measure11,
      this.measure12,
      this.measure13,
      this.measure14,
      this.measure15,
      this.measure16,
      this.measure17,
      this.measure18,
      this.measure19,
      this.measure20,
      this.youtube});

  @override
  State<RecipeDetails> createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ColorsConstants.whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: ColorsConstants.darkGreen,
        title: Text(widget.nameRecipe,
            style: const TextStyle(
                color: ColorsConstants.darkGreen,
                fontSize: 30,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: ColorsConstants.whiteColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: height * 0.02, horizontal: width * 0.12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: Image.network(widget.imageRecipe,
                    height: 300, fit: BoxFit.fitWidth),
              ),
              SizedBox(height: height * 0.02),
              const Text(
                'Ingredients',
                style: TextStyle(
                    color: ColorsConstants.darkGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
              if (widget.ingredient1 != '' && widget.measure1 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient1!}: ${widget.measure1!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient2 != '' && widget.measure2 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient2!}: ${widget.measure2!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient3 != '' && widget.measure3 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient3!}: ${widget.measure3!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient4 != '' && widget.measure4 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient4!}: ${widget.measure4!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient5 != '' && widget.measure5 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient5!}: ${widget.measure5!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient6 != '' && widget.measure6 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient6!}: ${widget.measure6!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient7 != '' && widget.measure7 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient7!}: ${widget.measure7!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient8 != '' && widget.measure8 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient8!}: ${widget.measure8!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient9 != '' && widget.measure9 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient9!}: ${widget.measure9!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient10 != '' && widget.measure10 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient10!}: ${widget.measure10!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient11 != '' && widget.measure11 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient11!}: ${widget.measure11!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient12 != '' && widget.measure12 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient12!}: ${widget.measure12!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient13 != '' && widget.measure13 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient13!}: ${widget.measure13!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient14 != '' && widget.measure14 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient14!}: ${widget.measure14!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient15 != '' && widget.measure15 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient15!}: ${widget.measure15!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient16 != '' && widget.measure16 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient16!}: ${widget.measure16!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient17 != '' && widget.measure17 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient17!}: ${widget.measure17!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient18 != '' && widget.measure18 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient18!}: ${widget.measure18!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient19 != '' && widget.measure19 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient19!}: ${widget.measure19!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              if (widget.ingredient20 != '' && widget.measure20 != '') ...[
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  '- ${widget.ingredient20!}: ${widget.measure20!}',
                  style: const TextStyle(
                      fontSize: 16, color: ColorsConstants.darkGreen),
                )
              ],
              SizedBox(
                height: height * 0.02,
              ),
              const Text(
                'Instructions',
                style: TextStyle(
                    color: ColorsConstants.darkGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text(
                widget.instructions,
                style: const TextStyle(
                    fontSize: 16, color: ColorsConstants.darkGreen),
              )
            ],
          ),
        ),
      ),
    );
  }
}