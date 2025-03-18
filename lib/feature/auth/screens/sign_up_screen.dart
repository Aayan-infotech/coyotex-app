import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  bool _isFormValid = false;

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  void initState() {
    super.initState();

    // Add listeners to each field to update form validity
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _mobileNumberController.addListener(_validateForm);
    _fullNameController.addListener(_validateForm);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required.";
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address.";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required.";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters.";
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return "Mobile number is required.";
    }
    if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return "Enter a valid 10-digit mobile number.";
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return "Full name is required.";
    }
    return null;
  }

  void _onSignupPressed(
      BuildContext context, UserViewModel authProvider) async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;
      final referralCode = _referralController.text;
      final fullName = _fullNameController.text;
      final mobileNumber = _mobileNumberController.text;

      if (password != confirmPassword) {
        _showErrorSheet(context, "Passwords do not match. Please try again.");
      } else {
        ApiResponseWithData responseWithData = await authProvider.signUp(
            fullName, mobileNumber, password, referralCode, email);
        if (responseWithData.success) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return OtpScreen(
              email: _emailController.text,
            );
          }));
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Signup Failed"),
                content: Text(responseWithData.message ??
                    "An error occurred during signup. Please try again."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Dismiss"),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<UserViewModel>(
        builder: (context, authProvider, child) {
          return authProvider.isLoading
              ? Center(
                  child: CircularProgressIndicator.adaptive(
                  backgroundColor: Colors.white,
                ))
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Image.asset(
                                "assets/images/logo.png",
                              ),
                            ),
                            const SizedBox(height: 20),
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
                              controller: _fullNameController,
                              labelText: "Full Name",
                              validator: _validateFullName,
                            ),
                            const SizedBox(height: 20),
                            BrandedTextField(
                              prefix: const Icon(Icons.phone),
                              controller: _mobileNumberController,
                              keyboardType: TextInputType.number,
                              labelText: "Mobile Number",
                              validator: _validateMobile,
                            ),
                            const SizedBox(height: 20),
                            BrandedTextField(
                              prefix: const Icon(Icons.email),
                              controller: _emailController,
                              labelText: "Email",
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 20),
                            BrandedTextField(
                              prefix: const Icon(Icons.lock),
                              controller: _passwordController,
                              labelText: "Password",
                              isPassword: true,
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 20),
                            BrandedTextField(
                              prefix: const Icon(Icons.lock_outline),
                              controller: _confirmPasswordController,
                              labelText: "Confirm Password",
                              isPassword: true,
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 20),
                            BrandedTextField(
                              prefix: const Icon(Icons.card_giftcard),
                              controller: _referralController,
                              labelText: "Referral Code (Optional)",
                            ),
                            const SizedBox(height: 30),
                            BrandedPrimaryButton(
                              isEnabled:
                                  _isFormValid && !authProvider.isLoading,
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
                  ),
                );
        },
      ),
    );
  }
}
