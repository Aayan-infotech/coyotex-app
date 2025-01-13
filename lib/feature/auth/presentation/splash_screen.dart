import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'welcome_screen.dart'; // Import the WelcomeScreen

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to WelcomeScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image 1: Logo
            Image.asset("assets/images/logo.png"),
            const SizedBox(
              height: 10,
            ),
            // Image 2: Logo Text
            Image.asset("assets/images/logo_text.png"),
          ],
        ),
      ),
    );
  }
}
