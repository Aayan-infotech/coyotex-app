import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  bool isEnabled = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    _usernameController.text = userProvider.user.name;
    _mobileNumberController.text = userProvider.user.number;
    _emailController.text = userProvider.user.email;
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
            child: Consumer<UserViewModel>(
              builder: (context, provider, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${provider.user.name}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 50),
                    BrandedTextField(
                      prefix: const Icon(Icons.person),
                      controller: _usernameController,
                      labelText: "Username",
                      onChanged: (value) => setState(() => isEnabled = true),
                    ),
                    const SizedBox(height: 20),
                    BrandedTextField(
                      prefix: const Icon(Icons.email),
                      controller: _emailController,
                      labelText: "Email",
                      isEnabled: false,
                    ),
                    const SizedBox(height: 20),
                    BrandedTextField(
                      prefix: const Icon(Icons.phone),
                      controller: _mobileNumberController,
                      labelText: "Mobile Number",
                      onChanged: (value) => setState(() => isEnabled = true),
                    ),
                    const SizedBox(height: 30),
                    provider.isLoading
                        ? const CircularProgressIndicator()
                        : BrandedPrimaryButton(
                            isEnabled: isEnabled,
                            name: "Save",
                            onPressed: () async {
                              var response = await provider.updateUserProfile(
                                _usernameController.text,
                                _mobileNumberController.text,
                                provider.user.userPlan,
                                provider.user.userWeatherPref,
                              );

                              if (response.success) {
                                AppDialog.showSuccessDialog(
                                  context,
                                  response.message,
                                  () => Navigator.of(context)
                                    ..pop()
                                    ..pop(),
                                );
                              } else {
                                AppDialog.showErrorDialog(
                                  context,
                                  response.message,
                                  () => Navigator.of(context).pop(),
                                );
                              }
                            },
                          ),
                    const SizedBox(height: 20),
                    BrandedPrimaryButton(
                      isUnfocus: true,
                      isEnabled: true,
                      name: "Cancel",
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 100),
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
