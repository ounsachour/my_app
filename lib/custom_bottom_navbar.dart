import 'package:flutter/material.dart';

import 'elderly_home_page.dart';
import 'elderly_profile.dart';
import 'notifications_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int unreadNotifications;
  final int currentIndex;
  final String firstName;
  final int patientId;
  final int userId;

  const CustomBottomNavBar({
  super.key,
  required this.currentIndex,
  required this.firstName,
  required this.patientId,
  required this.userId,
  required this.unreadNotifications,
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

          GestureDetector(

  onTap: () {

    if (2 == currentIndex) return;

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) => NotificationsPage(

          userId: userId,

          patientId: patientId,

          firstName: firstName,
        ),
      ),
    );
  },

  child: Stack(

    clipBehavior: Clip.none,

    children: [

      AnimatedContainer(

        duration: const Duration(
          milliseconds: 300,
        ),

        curve: Curves.easeInOut,

        width:
            currentIndex == 2
                ? 60
                : 50,

        height:
            currentIndex == 2
                ? 60
                : 50,

        decoration: BoxDecoration(

          color:
              currentIndex == 2
                  ? Colors.white
                  : Colors.transparent,

          shape: BoxShape.circle,
        ),

        child: Icon(

          Icons.notifications_rounded,

          size:
              currentIndex == 2
                  ? 30
                  : 26,

          color:
              currentIndex == 2
                  ? const Color(
                      0xFF005B5B,
                    )
                  : Colors.white70,
        ),
      ),

      if (unreadNotifications > 0)

        Positioned(

          right: -2,
          top: -2,

          child: Container(

            width: 18,
            height: 18,

            decoration:
                const BoxDecoration(

              color: Colors.red,

              shape:
                  BoxShape.circle,
            ),
          ),
        ),
    ],
  ),
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
                userId: userId,
            );

            break;

          case 2:

    page = NotificationsPage(

  userId: userId,

  patientId: patientId,

  firstName: firstName,
);

    break;

          case 3:

            page = ProfilePage(
              firstName: firstName,
              patientId: patientId,
              userId: userId,
            );

            break;

          default:

            page = ElderlyHomePage(
              firstName: firstName,
              patientId: patientId,
              userId: userId,
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