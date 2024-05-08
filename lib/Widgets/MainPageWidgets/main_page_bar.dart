import 'package:flutter/material.dart';

import 'package:nutrisalud/Helpers/helpers_export.dart';

class MainPageBar extends StatelessWidget {
  final String userAvatar;

  const MainPageBar({super.key, required this.userAvatar});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: ColorsConstants.darkGreen),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              border: Border.all(color: ColorsConstants.darkGreen),
            ),
            margin: const EdgeInsets.only(left: 5, right: 15),
            height: 40,
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            width: screenWidth * 0.75,
            child: TextFormField(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.search),
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: ColorsConstants.darkGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
