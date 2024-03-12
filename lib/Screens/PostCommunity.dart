import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Helpers/HelpersExport.dart';

class PostCommunity extends StatefulWidget {
  const PostCommunity({super.key});

  @override
  State<PostCommunity> createState() => _PostCommunityState();
}

class _PostCommunityState extends State<PostCommunity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsConstants.whiteColor,
      appBar: AppBar(
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
            child: ElevatedButton(
              onPressed: (){},
              style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => ColorsConstants.darkGreen)),
              child: const Text('Post', style: TextStyle(color: ColorsConstants.whiteColor, fontWeight: FontWeight.w500)),
            ),
          )
        ],
        foregroundColor: ColorsConstants.darkGreen,
        backgroundColor: ColorsConstants.whiteColor
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: const TextField(
          style: TextStyle(decoration: TextDecoration.none),
          expands: true,
          maxLines: null, // Establece maxLines en null para que el TextField pueda crecer según sea necesario
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Contenido del comentario',
          ),
        ),
      ),

    );
  }
}
