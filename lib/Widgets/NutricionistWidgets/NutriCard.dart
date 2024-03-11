import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Helpers/Colors.dart';

class NutriCard extends StatelessWidget {
  final String foto;
  final String nombre;
  final String descripcion;
  final double calificacion;
  final String skill_1;
  final String? skill_2;
  final String? skill_3;
  final String? whatsapp;
  final String? instagram;
  final String email;
  final String web_site;

  const NutriCard(
      {super.key,
      required this.foto,
      required this.nombre,
      required this.descripcion,
      required this.calificacion,
      required this.skill_1,
      this.skill_2,
      this.skill_3,
      this.whatsapp,
      this.instagram,
      required this.email,
      required this.web_site});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return FlipCard(
      fill: Fill.fillBack,
      direction: FlipDirection.HORIZONTAL,
      side: CardSide.FRONT,
      front: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: ColorsConstants.lightGreen,
        ),
        height: screenHeight * 0.65,
        width: screenWidth * 0.75,
        child: Column(
          children: [
            Container(
              width: screenWidth * 0.75,
              height: screenWidth * 0.75,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                image: DecorationImage(
                  image: AssetImage(foto),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Center(
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.025),
                          child: Text(
                            nombre,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: screenWidth * 0.05),
                          child: Text(
                            descripcion,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w200,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                print("Save tapped");
                              },
                              child: const Icon(
                                Icons.bookmark_border,
                                fill: 1,
                                color: Color(0xffffffff),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            GestureDetector(
                              onTap: () {
                                print("Share tapped");
                              },
                              child: const Icon(
                                Icons.share,
                                color: Color(0xffffffff),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              calificacion
                                  .toString(), // Calificacion del nutricionista
                              style: const TextStyle(color: Color(0xffffffff)),
                            ),
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xffffffff),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      back: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: ColorsConstants.lightGreen,
        ),
        height: screenHeight * 0.7,
        width: screenWidth * 0.75,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Center(
            child: Column(
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '• $skill_1',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                  ),
                ),
                if (skill_2 != null)
                  Text(
                    '• $skill_2',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                if (skill_3 != null)
                  Text(
                    '• $skill_3',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                const Spacer(),
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        await launch(
                            'mailto:$email'); // Reemplaza por el URL deseado
                      },
                      child: const Icon(
                        Icons.mail_outline,
                        size: 30.0,
                        color: Colors.white,
                      ),
                    ),
                    if (instagram != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: GestureDetector(
                          onTap: () async {
                            await launch(
                                'https://www.instagram.com/$instagram/');
                          },
                          child: const FaIcon(
                            FontAwesomeIcons.instagram,
                            size: 30.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (whatsapp != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: GestureDetector(
                          onTap: () async {
                            await launch(
                                'https://api.whatsapp.com/send?phone=+$whatsapp&text=Nutrisalud');
                          },
                          child: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            size: 30.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    await launch('https://$web_site');
                  },
                  child: Text(
                    web_site,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
