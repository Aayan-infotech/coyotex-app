import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/auth/screens/otp_screen.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final TextEditingController _emailController = TextEditingController();

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
                  controller: _emailController,
                  labelText: "Email",
                ),
                const SizedBox(height: 30),
                Consumer<UserViewModel>(
                  builder: (context, provider, child) {
                    return BrandedPrimaryButton(
                      isEnabled: !provider.isLoading,
                      name: provider.isLoading ? "Please Wait..." : "Continue",
                      onPressed: () async {
                        if (_emailController.text.isEmpty) {
                          _showErrorMessage(context, "Please enter your email");
                          return;
                        }

                        var response = await provider
                            .forgotPassword(_emailController.text);

                        if (response.success) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return OtpScreen(
                                  email: _emailController.text,
                                  isResetPassward: true,
                                );
                              },
                            ),
                          );
                        } else {
                          _showErrorMessage(
                              context, response.message ?? "An error occurred");
                        }
                      },
                    );
                  },
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
