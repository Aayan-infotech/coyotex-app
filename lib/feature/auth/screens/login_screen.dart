import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/forget_password.dart';
import 'package:coyotex/feature/auth/screens/sign_up_screen.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:coyotex/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/lower_case_text_formatter.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  _showErrorDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                "Error",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
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
            child: Consumer<UserViewModel>(
              builder: (context, userProvider, child) {
                return userProvider.isLoading
                    ? const CircularProgressIndicator()
                    : Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/logo.png",
                              width: MediaQuery.of(context).size.width * 0.2,
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "Welcome Back",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Text(
                              "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
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
                              labelText: "Email/Username",
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => validateEmail(value),
                              inputFormatters: [LowerCaseTextFormatter()],
                            ),
                            const SizedBox(height: 20),
                            BrandedTextField(
                              prefix: const Icon(Icons.lock),
                              controller: _passwordController,
                              isPassword: true,
                              labelText: "Password",
                              validator: (value) => validatePassword(value),
                            ),
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return ForgotPassword();
                                    }),
                                  );
                                },
                                child: const Text(
                                  "Forgot Password",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            BrandedPrimaryButton(
                              isEnabled: true,
                              name: "Login",
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final username = _nameController.text;
                                  final password = _passwordController.text;

                                  var response = await userProvider.login(
                                      username, password, context);

                                  if (response.success) {
                                    SharedPrefUtil.setValue(isLoginPref, true);
                                  } else {
                                    AppDialog.showErrorDialog(
                                        context, response.message, () {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            BrandedPrimaryButton(
                              isUnfocus: true,
                              isEnabled: true,
                              name: "Create Account",
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return SignupScreen();
                                  }),
                                );
                              },
                            ),
                          ],
                        ),
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}
