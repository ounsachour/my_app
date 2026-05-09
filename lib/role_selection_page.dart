import 'package:flutter/material.dart';
import 'register_elderly.dart';
import 'register_family.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF005B5B),
              Color(0xFF007777),
            ],
          ),
        ),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),

            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 35,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),

                  // Shadow
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    // ICON CONTAINER
                    Container(
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4F4),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.people_alt_rounded,
                        size: 65,
                        color: Color(0xFF005B5B),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // TITLE
                    const Text(
                      "Join us as:",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // SUBTITLE
                    const Text(
                      "Choose your role to continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // ELDERLY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 60,

                      child: ElevatedButton(
                         onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterElderly(),
                            ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005B5B),
                          elevation: 4,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),

                        child: const Text(
                          "Elderly",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FAMILY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 60,

                      child: ElevatedButton(
                        onPressed: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder: (context) =>
                                const RegisterFamily(),
                          ),
                        );
                      },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,

                          side: const BorderSide(
                            color: Color(0xFF005B5B),
                            width: 2,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),

                        child: const Text(
                          "Family Member",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF005B5B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}