import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/login_screen.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordScreen extends StatefulWidget {
  final bool? isResetPassward;
  final String email;
  final String otp;
  const PasswordScreen(
      {this.isResetPassward = false,
      required this.email,
      required this.otp,
      super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
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
        return const SizedBox(
          width: double.infinity,
          child: Padding(
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
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: Consumer<UserViewModel>(
        builder: (context, provider, child) {
          return provider.isLoading
              ? const Center(child: CircularProgressIndicator())
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
                            "Change Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            "Enter your current password and choose a new one to update your credentials.",
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
                            controller: _nameController,
                            labelText: "New Password",
                          ),
                          const SizedBox(height: 20),
                          BrandedTextField(
                            prefix: const Icon(Icons.lock),
                            controller: _passwordController,
                            labelText: "Confirm New Password",
                          ),
                          const SizedBox(height: 30),
                          BrandedPrimaryButton(
                            isEnabled: true,
                            name: "Save",
                            onPressed: () async {
                              // Reset password logic
                              var response = await provider.resetPassword(
                                widget.email,
                                widget.otp,
                                _passwordController.text,
                              );

                              if (response.success) {
                                AppDialog.showSuccessDialog(context,
                                    "Your password has been set successfully.",
                                    () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const LoginScreen()), // Redirect to login screen
                                  );
                                });
                                // Show a success dialog
                              } else {
                                // Handle erro
                                AppDialog.showErrorDialog(
                                    context, response.message, () {});
                              }
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
