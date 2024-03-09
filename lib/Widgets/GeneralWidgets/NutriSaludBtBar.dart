import 'package:flutter/material.dart';
import 'package:nutrisalud/Screens/Community.dart';
import 'package:nutrisalud/Screens/MainPage.dart';
import 'package:nutrisalud/Screens/Nutricionists.dart';
import 'package:nutrisalud/Screens/Screens.dart';

class NutriSaludBtBar extends StatefulWidget {
  const NutriSaludBtBar({super.key});

  @override
  State<NutriSaludBtBar> createState() => _NutriSaludBtBarState();
}

class _NutriSaludBtBarState extends State<NutriSaludBtBar> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: _onPageChanged,
        children: const [
          MainPage(),
          Nutricionists(),
          RecomendedFood(),
          Community(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xffF5F5F5),
        selectedIconTheme: const IconThemeData(color: Color(0xff527450)),
        unselectedIconTheme: const IconThemeData(color: Color(0xffA9A9A9)),
        unselectedItemColor: const Color(0xffD9D9D9),
        showUnselectedLabels: true,
        fixedColor: const Color(0xff527450),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.content_paste_search_sharp),
              label: 'Nutricionist'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), label: 'Foods'),
          BottomNavigationBarItem(
              icon: Icon(Icons.comment_outlined), label: 'Community')
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
