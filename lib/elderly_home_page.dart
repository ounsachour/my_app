import 'package:flutter/material.dart';
import 'custom_bottom_navbar.dart';

class ElderlyHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Home"),
      ),

      body: const Center(
        child: Text(
          "Welcome Home",
          style: TextStyle(fontSize: 24),
        ),
      ),

      bottomNavigationBar:
          const CustomBottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}