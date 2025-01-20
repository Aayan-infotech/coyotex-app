import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/auth/screens/otp_screen.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showIncorrectPasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Pallete.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  "Incorrect Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // const SizedBox(height: 10),
                // const Text(
                //   "The password you entered is incorrect. Please try again.",
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     color: Colors.white70,
                //     fontSize: 14,
                //   ),
                // ),
                // const SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () => Navigator.pop(context),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.red,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //   ),
                //   child: const Text("Dismiss"),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onLoginPressed() {
    final password = _passwordController.text;

    // Dummy check for incorrect password
    // if (password != "123456") {
    //   _showIncorrectPasswordSheet(context);
    // } else {
    //   // Handle successful login
    //   // For example, navigate to another screen
    // }
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return OtpScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  width: MediaQuery.of(context).size.width * 0.2,
                ),
                const SizedBox(height: 30),
                const Text(
                  "Recover Password",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
                const Text(
                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),
                BrandedTextField(
                  prefix: const Icon(Icons.person),
                  controller: _nameController,
                  labelText: "Email",
                ),
                const SizedBox(height: 30),
                BrandedPrimaryButton(
                  isEnabled: true,
                  name: "Continue",
                  onPressed: _onLoginPressed,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.3,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
