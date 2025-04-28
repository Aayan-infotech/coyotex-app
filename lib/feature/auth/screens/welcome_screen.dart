import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/auth/screens/login_screen.dart';
import 'package:coyotex/utils/keyboard_extension.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return GestureDetector(
      onTap: () {
        context.hideKeyboard();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Image.asset(
              "assets/images/welcome_background.png",
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            SingleChildScrollView(
              child: SizedBox(
                height: height,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.28),

                    // Logo
                    Image.asset(
                      "assets/images/logo.png",
                      width: width * 0.35,
                    ),
                    const SizedBox(height: 10),

                    // Logo Text
                    Image.asset(
                      "assets/images/logo_text.png",
                      width: width * 0.6,
                    ),

                    SizedBox(height: height * 0.08),

                    // Title Text
                    Text(
                      "GRIND AND FIND",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.075,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "start the journey now",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.055,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.08,
                        vertical: height * 0.02,
                      ),
                      child: const Text(
                        "Your go-to hunting companion! Track, plan, and record your adventures with ease. Stay informed, stay safe, and make every hunt count!.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                      child: BrandedPrimaryButton(
                        isEnabled: true,
                        suffixIcon: const Icon(Icons.arrow_forward,
                            color: Colors.white),
                        name: "I'm ready to begin",
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ));
                        },
                      ),
                    ),
                    SizedBox(height: height * 0.06),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
