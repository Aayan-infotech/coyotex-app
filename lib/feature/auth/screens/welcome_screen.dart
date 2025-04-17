import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            "assets/images/welcome_background.png",
            fit: BoxFit.cover, 
            height: double.infinity, // Ensure the image takes up full height
            width: double.infinity, // Ensure the image takes up full width
          ),
          Center(
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                const Text(
                  "GRIND AND FIND",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800),
                ),
                const Text(
                  "start the journey now",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500),
                ),
                const Text(
                  "Your go-to hunting companion! Track, plan, and record your adventures with ease. Stay informed, stay safe, and make every hunt count!.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 100, // Adjust this value to control the vertical position
            left: 0,
            right: 0,

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: BrandedPrimaryButton(
                isEnabled: true,
                suffixIcon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
                name: "I'am ready to begin",
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const LoginScreen();
                  }));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
