
import 'dart:async';
import 'package:flutter/material.dart';


class WelcomePage extends StatefulWidget {

  final Widget nextPage;

  const WelcomePage({
    super.key,
    required this.nextPage,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {

  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> scaleAnimation;
  late Animation<double> pulseAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    scaleAnimation = Tween<double>(
      begin: 0.2,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_fadeController);

    _scaleController.forward();
    _fadeController.forward();

    _pulseController.repeat(reverse: true);

    // AUTO NAVIGATION

    Timer(const Duration(seconds: 3), () {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(
          builder: (context) =>
            widget.nextPage,
        ),
      );
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF005B5B),

      body: Center(

        child: FadeTransition(

          opacity: fadeAnimation,

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              AnimatedBuilder(

                animation: pulseAnimation,

                builder: (context, child) {

                  return Transform.scale(

                    scale: pulseAnimation.value,

                    child: ScaleTransition(

                      scale: scaleAnimation,

                      child: Container(

                        width: 170,
                        height: 170,

                        decoration: BoxDecoration(

                          shape: BoxShape.circle,

                          color: Colors.white,

                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.35),
                              blurRadius: 35,
                              spreadRadius: 10,
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.check_rounded,
                          size: 100,
                          color: Color(0xFF005B5B),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 45),

              const Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 15),

              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 40,
                ),

                child: Text(
                  "Your account has been created successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 45),

              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
