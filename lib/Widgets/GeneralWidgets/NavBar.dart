import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final bool backButton;
  final VoidCallback backRoute;
  final String? title;
  final bool updateButton;
  final VoidCallback updateRoute;

  const NavBar({
    super.key,
    required this.backButton,
    required this.backRoute,
    this.title,
    required this.updateButton,
    required this.updateRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          if (backButton == true) ...[
            GestureDetector(
              onTap: () {
                backRoute();
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 24,
                  color: Color(0xff3A5A40),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(
              width: 34,
            ),
          ],
          if (title != null) ...[
            const Spacer(),
            Text(
              title!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 26.5,
                fontWeight: FontWeight.bold,
                color: Color(0xff3A5A40),
              ),
            ),
            const Spacer(),
          ] else ...[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xff3A5A40),
                  ),
                ),
                child: const TextField(
                  autofocus: true,
                  maxLength: 30,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Color(0xff3A5A40)),
                    hintText: 'Search',
                    counterText: '',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
          if (updateButton == true) ...[
            GestureDetector(
              onTap: () {
                updateRoute();
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.sync,
                  size: 24,
                  color: Color(0xff3A5A40),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(
              width: 34,
            ),
          ],
        ],
      ),
    );
  }
}
