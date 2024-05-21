import 'package:flutter/material.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';

class PostProTip extends StatefulWidget {
  const PostProTip({super.key});

  @override
  State<PostProTip> createState() => _PostProTipState();
}

class _PostProTipState extends State<PostProTip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsConstants.whiteColor,
      appBar: AppBar(
          actions: [
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => ColorsConstants.darkGreen)),
                child: const Text('Post',
                    style: TextStyle(
                        color: ColorsConstants.whiteColor,
                        fontWeight: FontWeight.w500)),
              ),
            )
          ],
          foregroundColor: ColorsConstants.darkGreen,
          backgroundColor: ColorsConstants.whiteColor),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Row(
              children: [
                Text(
                  'Titulo del tip',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: ColorsConstants.darkGreen,
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.01,
              ),
              height: MediaQuery.of(context).size.height * 0.1,
              padding: const EdgeInsets.all(16.0),
              child: const TextField(
                style: TextStyle(decoration: TextDecoration.none),
                expands: true,
                maxLines:
                    null, // Establece maxLines en null para que el TextField pueda crecer según sea necesario
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Escribe aquí...',
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Divider(color: ColorsConstants.darkGreen, height: 1),
            const SizedBox(
              height: 15,
            ),
            const Row(
              children: [
                Text(
                  'Contenido de tip',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: ColorsConstants.darkGreen,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.01,
                    horizontal: MediaQuery.of(context).size.width * 0.04),
                child: const TextField(
                  style: TextStyle(decoration: TextDecoration.none),
                  expands: true,
                  maxLines:
                      null, // Establece maxLines en null para que el TextField pueda crecer según sea necesario
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Escribe aquí...',
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
