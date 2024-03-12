import 'package:flutter/material.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import 'package:nutrisalud/Helpers/HelpersExport.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ColorsConstants.whiteColor,
      child: Column(
        children: [

        ],
      ),
    );
  }
}
