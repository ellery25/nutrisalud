import 'package:flutter/material.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import '../../Helpers/Colors.dart';

class MainPageBar extends StatelessWidget {
  final String userAvatar;

  const MainPageBar({super.key, required this.userAvatar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
      child: Row(children: [
        CircleAvatar(backgroundImage: NetworkImage(userAvatar)),
        Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              border: Border.all(color: ColorsConstants.darkGreen)),
          margin: const EdgeInsets.symmetric(horizontal: 15),
          height: 40,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
          width: MediaQuery.of(context).size.width * 0.75,
          child: TextFormField(
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.Search),
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: ColorsConstants.darkGreen,
                )),
          ),
        ),
      ]),
    );
  }
}
