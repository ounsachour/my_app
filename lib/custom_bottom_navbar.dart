import 'package:flutter/material.dart';

import 'elderly_home_page.dart';
import 'elderly_profile.dart';

class CustomBottomNavBar extends StatelessWidget {

  final int currentIndex;
  final String firstName;
  final int patientId;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.firstName,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20,
      ),

      height: 80,

      decoration: BoxDecoration(

        color: const Color(0xFF005B5B),

        borderRadius: BorderRadius.circular(30),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment.spaceAround,

        children: [

          buildNavItem(
            context,
            icon: Icons.home_rounded,
            index: 0,
          ),

          buildNavItem(
            context,
            icon: Icons.favorite_rounded,
            index: 1,
          ),

          buildNavItem(
            context,
            icon: Icons.notifications_rounded,
            index: 2,
          ),

          buildNavItem(
            context,
            icon: Icons.person_rounded,
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget buildNavItem(
    BuildContext context, {
    required IconData icon,
    required int index,
  }) {

    final bool isActive =
        currentIndex == index;

    return GestureDetector(

      onTap: () {

        if (index == currentIndex) return;

        Widget page;

        switch (index) {

          // HOME

          case 0:

            page = ElderlyHomePage(
              firstName: firstName,
                patientId: patientId,
            );

            break;

          // PROFILE

          case 3:

            page = ProfilePage(
  firstName: firstName,
   patientId: patientId,
);

            break;

          default:

            page = ElderlyHomePage(
              firstName: firstName,
              patientId: patientId,
            );
        }

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },

      child: AnimatedContainer(

        duration: const Duration(
          milliseconds: 300,
        ),

        curve: Curves.easeInOut,

        width: isActive ? 60 : 50,
        height: isActive ? 60 : 50,

        decoration: BoxDecoration(

          color: isActive
              ? Colors.white
              : Colors.transparent,

          shape: BoxShape.circle,

          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.35),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),

        child: Icon(

          icon,

          size: isActive ? 30 : 26,

          color: isActive
              ? const Color(0xFF005B5B)
              : Colors.white70,
        ),
      ),
    );
  }
}