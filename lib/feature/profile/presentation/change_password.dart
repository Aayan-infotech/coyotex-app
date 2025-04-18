import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/login_screen.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:coyotex/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool? isResetPassward;
  final String email;
  final String otp;
  const ChangePasswordScreen(
      {this.isResetPassward = false,
      required this.email,
      required this.otp,
      super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Consumer<UserViewModel>(
        builder: (context, provider, child) {
          return provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        //  mainAxisAlignment: MainAxisAlignment.center,
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
                            "Create a strong password to keep your account secure.",
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
                            controller: _oldPasswordController,
                            labelText: "Old Password",
                            keyboardType: TextInputType.visiblePassword,
                            validator: (value) => validateFiled(
                                value, "Old password is required!"),
                          ),
                          const SizedBox(height: 20),
                          BrandedTextField(
                            prefix: const Icon(Icons.lock),
                            controller: _newPasswordController,
                            labelText: "New Password",
                            validator: (value) => validatePassword(value),
                          ),
                          const SizedBox(height: 20),
                          BrandedTextField(
                            prefix: const Icon(Icons.lock),
                            controller: _confirmPasswordController,
                            labelText: "Confirm New Password",
                            validator: (value) => validateConfirmPassword(
                                value, _newPasswordController.text),
                          ),
                          const SizedBox(height: 50),
                          BrandedPrimaryButton(
                            isEnabled: true,
                            name: "Save",
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                var response = await provider.changePassword(
                                  _oldPasswordController.text,
                                  _newPasswordController.text,
                                  _confirmPasswordController.text,
                                );

                                if (response.success) {
                                  // Show a success dialog
                                  AppDialog.showSuccessDialog(
                                      context, response.message, () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const LoginScreen()),
                                      (route) => false,
                                    );
                                  });
                                } else {
                                  // Handle error
                                  AppDialog.showErrorDialog(
                                      context, response.message, () {
                                    Navigator.of(context).pop();
                                  });
                                }
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
