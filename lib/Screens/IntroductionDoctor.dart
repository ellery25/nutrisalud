import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:nutrisalud/Helpers/HelpersExport.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import 'package:flutter/material.dart';

class IntroductionDoctor extends StatefulWidget {
  const IntroductionDoctor({super.key});

  @override
  State<IntroductionDoctor> createState() => _IntroductionDoctorState();
}

class _IntroductionDoctorState extends State<IntroductionDoctor> {
  @override
  Widget build(BuildContext context) {

    final pages = [
      PageViewModel(
          title: 'Make Tips!',
          body:
          'Create tips to recommend to people to improve their diet or nutrition.',
          image: SvgPicture.asset(AssetsRoute.bulbSvg, color: ColorsConstants.darkGreen, height: MediaQuery.of(context).size.height * 0.25),
          decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                  color: ColorsConstants.darkGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              bodyTextStyle:
              TextStyle(color: ColorsConstants.darkGreen, fontSize: 16))),
      PageViewModel(
          title: 'Improve the nutrition of your users',
          body:
          'You will be able to have consultation sessions with your patients',
          image: SvgPicture.asset(AssetsRoute.commentSvg, color: ColorsConstants.darkGreen, height: MediaQuery.of(context).size.height * 0.25),
          decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                  color: ColorsConstants.darkGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              bodyTextStyle:
              TextStyle(color: ColorsConstants.darkGreen, fontSize: 16))),
    ];

    return IntroductionScreen(
      globalHeader: AppBar(
        backgroundColor: ColorsConstants.lightGreen,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Nutrisalud',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: ColorsConstants.whiteColor)),
      ),
      bodyPadding:
      EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
      pages: pages,
      dotsDecorator:
      const DotsDecorator(activeColor: ColorsConstants.darkGreen),
      showNextButton: false,
      done: const Text('Next',
          style: TextStyle(color: ColorsConstants.darkGreen)),
      onDone: () {

        //Este button manda a la pestaña principal

        Navigator.pushReplacementNamed(context, AppRoutes.home);

      },
    );
  }
}
