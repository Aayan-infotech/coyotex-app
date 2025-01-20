import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/otp_screen.dart';
import 'package:coyotex/feature/auth/screens/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  void _showErrorSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Pallete.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Dismiss"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSignupPressed(
      BuildContext context, UserViewModel authProvider) async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final referralCode = _referralController.text;

    if (password != confirmPassword) {
      _showErrorSheet(context, "Passwords do not match. Please try again.");
    } else if (username.isEmpty || password.isEmpty || email.isEmpty) {
      _showErrorSheet(context, "Please fill out all required fields.");
    } else {
      ApiResponseWithData responseWithData =
          await authProvider.signUp(username, password, referralCode, email);
      if (responseWithData.success) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return OtpScreen(
            email: _emailController.text,
          );
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<UserViewModel>(
        builder: (context, authProvider, child) {
          return authProvider.isLoading
              ? Center(child: CircularProgressIndicator.adaptive())
              : Center(
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
                            "Create Account",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                          ),
                          const Text(
                            "Join us and explore the world of possibilities.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 30),
                          BrandedTextField(
                            prefix: const Icon(Icons.person),
                            controller: _usernameController,
                            labelText: "Username",
                          ),
                          const SizedBox(height: 20),
                          BrandedTextField(
                            prefix: const Icon(Icons.email),
                            controller: _emailController,
                            labelText: "Email",
                          ),
                          const SizedBox(height: 20),
                          BrandedTextField(
                            prefix: const Icon(Icons.lock),
                            controller: _passwordController,
                            labelText: "Password",
                            isPassword: true,
                          ),
                          const SizedBox(height: 20),
                          BrandedTextField(
                            prefix: const Icon(Icons.lock_outline),
                            controller: _confirmPasswordController,
                            labelText: "Confirm Password",
                            isPassword: true,
                          ),
                          const SizedBox(height: 20),
                          BrandedTextField(
                            prefix: const Icon(Icons.card_giftcard),
                            controller: _referralController,
                            labelText: "Referral Code (Optional)",
                          ),
                          const SizedBox(height: 30),
                          BrandedPrimaryButton(
                            isEnabled: true,
                            name: "Sign Up",
                            onPressed: () =>
                                _onSignupPressed(context, authProvider),
                          ),
                          const SizedBox(height: 20),
                          BrandedPrimaryButton(
                            isUnfocus: true,
                            isEnabled: true,
                            name: "Back to Login",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
