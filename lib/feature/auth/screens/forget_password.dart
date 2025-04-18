import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/lower_case_text_formatter.dart';
import '../../../utils/validation.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  "Enter your email address to receive password recovery instructions.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),
                BrandedTextField(
                  prefix: const Icon(Icons.person),
                  controller: _emailController,
                  labelText: "Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => validateEmail(value),
                  inputFormatters: [LowerCaseTextFormatter()],
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
