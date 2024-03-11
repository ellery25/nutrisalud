import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:nutrisalud/Helpers/HelpersExport.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  @override
  Widget build(BuildContext context) {
    final pages = [
      PageViewModel(
          title: 'Find Recipes',
          body:
              'NutriSalud is an application developed to improve the quality of your nutrition, you can search for different food recipes.',
          image: Image.asset(AssetsRoute.foodPng,
              height: MediaQuery.of(context).size.height * 0.25),
          decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                  color: ColorsConstants.darkGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              bodyTextStyle:
                  TextStyle(color: ColorsConstants.darkGreen, fontSize: 16))),
      PageViewModel(
          title: 'Talk with the community',
          body:
              'Socialize with users in our community, share your lifestyle and learn from others.',
          image: Image.asset(AssetsRoute.communityPng,
              height: MediaQuery.of(context).size.height * 0.25),
          decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                  color: ColorsConstants.darkGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              bodyTextStyle:
                  TextStyle(color: ColorsConstants.darkGreen, fontSize: 16))),
      PageViewModel(
          title: 'Speak with a Nutricionist',
          body:
              'Do you need advice, do you have digestive problems, you can contact our Nutritionists, each one with different specializations that will help you with your diet.',
          image: Image.asset(AssetsRoute.doctorPng,
              height: MediaQuery.of(context).size.height * 0.25),
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

      },

    );
  }
}
