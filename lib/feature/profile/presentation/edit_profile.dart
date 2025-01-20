import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/auth/screens/subscription_screen.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _usernameController = TextEditingController();
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

  void _onSignupPressed() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showErrorSheet(context, "Passwords do not match. Please try again.");
    } else if (username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorSheet(context, "Please fill out all fields.");
    } else {
      // Handle successful signup logic here
      // For example, send data to the server
      print("Signup successful");
    }
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
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person),
                  // backgroundImage: AssetImage(
                  //     'assets/profile_picture.jpg'), // Replace with your image asset or network image.
                ),
                SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Fedelica Toraka',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.verified,
                              color: Colors.orange,
                              size: 20,
                            ),
                          ],
                        ),
                        Text(
                          '@Ella',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                BrandedTextField(
                  prefix: const Icon(Icons.person),
                  controller: _usernameController,
                  labelText: "Username",
                ),
                const SizedBox(height: 20),
                BrandedTextField(
                  prefix: const Icon(Icons.person),
                  controller: _passwordController,
                  labelText: "Email",
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                BrandedTextField(
                  prefix: const Icon(Icons.phone),
                  controller: _confirmPasswordController,
                  labelText: "Mobile Number",
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                BrandedTextField(
                  prefix: const Icon(Icons.card_giftcard),
                  controller: _referralController,
                  labelText: "Address",
                ),
                const SizedBox(height: 30),
                BrandedPrimaryButton(
                    isEnabled: true,
                    name: "Save",
                    onPressed: () {
                      Navigator.of(context).pop();
                    } //_onSignupPressed,
                    ),
                const SizedBox(height: 20),
                BrandedPrimaryButton(
                  isUnfocus: true,
                  isEnabled: true,
                  name: "Cancel",
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
  }
}
