import 'package:flutter/material.dart';
import 'package:nutrisalud/Screens/screens_export.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';

class NutrisaludBtBar extends StatefulWidget {
  const NutrisaludBtBar({super.key});

  @override
  State<NutrisaludBtBar> createState() => _NutrisaludBtBarState();
}

class _NutrisaludBtBarState extends State<NutrisaludBtBar> {
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
          RecommendedFood(),
          Community(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: ColorsConstants.whiteColor,
        selectedIconTheme:
            const IconThemeData(color: ColorsConstants.darkGreen),
        unselectedIconTheme: const IconThemeData(color: Color(0xff6F6C6C)),
        unselectedItemColor: const Color(0xff6F6C6C),
        showUnselectedLabels: true,
        fixedColor: ColorsConstants.darkGreen,
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
