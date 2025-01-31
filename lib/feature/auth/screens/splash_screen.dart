import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/core/utills/user_context_data.dart';
import 'package:coyotex/feature/homeScreen/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'welcome_screen.dart'; // Import the WelcomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState

    asyncInit();
    super.initState();
  }

  Future<void> asyncInit() async {
    try {
      await SharedPrefUtil.init();
      bool isLogin = SharedPrefUtil.getValue(isLoginPref, false) as bool;
      if (!isLogin) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        });
      } else {
        await UserContextData.setCurrentUserAndFetchUserData(context);
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        });
      }
    } catch (e) {
      // Handle the exception, e.g., log the error or show a message to the user
      print("An error occurred: $e");
      // Optionally, you can navigate to an error screen or show a dialog
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const ErrorScreen()),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Navigate to WelcomeScreen after 3 seconds

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
