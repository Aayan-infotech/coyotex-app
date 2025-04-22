import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/notification.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/forget_password.dart';
import 'package:coyotex/feature/auth/screens/sign_up_screen.dart';
import 'package:coyotex/feature/auth/screens/subscription_screen.dart';
import 'package:coyotex/feature/homeScreen/screens/home_screen.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:coyotex/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/lower_case_text_formatter.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text(
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

  bool isLoading = false;

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
                return isLoading
                    ? const Center(
                        child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                      ))
                    : Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                NotificationService.requestPermission();
                              },
                              child: Image.asset(
                                "assets/images/logo.png",
                                width: MediaQuery.of(context).size.width * 0.2,
                              ),
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
                              "Your go-to hunting companion! Track, plan, and record your adventures with ease. Stay informed, stay safe, and make every hunt count!.",
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
                              onChanged: (value) {
                                if (value.length >= 5) setState(() {});
                              },
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
                              isEnabled: _nameController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty,
                              name: "Login",
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                if (_formKey.currentState!.validate()) {
                                  final username = _nameController.text;
                                  final password = _passwordController.text;

                                  var response = await userProvider.login(
                                      username, password, context);
                                  if (response.success) {
                                    if (response.data["plan"] != null) {
                                      SharedPrefUtil.setValue(
                                          isLoginPref, true);
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeScreen()),
                                        (route) => false,
                                      );
                                    } else {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return const SubscriptionScreen(from: "login",);
                                      }));
                                    }
                                  } else {
                                    AppDialog.showErrorDialog(
                                        context, response.message, () {
                                      Navigator.of(context).pop();
                                      if (response.message ==
                                          "You have not verified your email. Please verify your email first.") {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return OtpScreen(
                                            email: _nameController.text,
                                          );
                                        }));
                                      }
                                    });

                                    setState(() {
                                      isLoading = false;
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
                                    return const SignupScreen();
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
