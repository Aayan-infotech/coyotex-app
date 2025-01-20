import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/forget_password.dart';
import 'package:coyotex/feature/auth/screens/sign_up_screen.dart';
import 'package:coyotex/feature/homeScreen/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  void _showErrorDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
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
                    : Column(
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
                          ),
                          const SizedBox(height: 20),
                          BrandedTextField(
                            prefix: const Icon(Icons.lock),
                            controller: _passwordController,
                            isPassword: true,
                            labelText: "Password",
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return ForgotPassword();
                                }));
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
                              final username = _nameController.text;
                              final password = _passwordController.text;

                              var response =
                                  await userProvider.login(username, password);

                              if (response.success) {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return HomeScreen();
                                }));
                              } else {
                                _showErrorDialog(response.message, context);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          BrandedPrimaryButton(
                            isUnfocus: true,
                            isEnabled: true,
                            name: "Create Account",
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return SignupScreen();
                              }));
                            },
                          ),
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}
