import 'dart:io';

import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isUploading = true; // Start showing the loader
      });

      await _uploadProfilePicture();

      setState(() {
        _isUploading = false; // Hide loader after upload
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_selectedImage == null) return;

    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    final String userId = userProvider.user.userId;

    try {
      String accessToken =
          SharedPrefUtil.getValue(accessTokenPref, "") as String;

      var uri = Uri.parse(
          "http://54.236.98.193:5647/api/users/update-profile-picture");
      var request = http.MultipartRequest("POST", uri)
        ..headers["Authorization"] = "Bearer $accessToken"
        ..files.add(
          await http.MultipartFile.fromPath(
            "profilePicture",
            _selectedImage!.path,
          ),
        );

      var response = await request.send();

      if (response.statusCode == 200) {
        AppDialog.showSuccessDialog(
            context, "Profile picture updated!", () => Navigator.pop(context));
      } else {
        AppDialog.showErrorDialog(context, "Failed to update profile picture",
            () => Navigator.pop(context));
      }
    } catch (e) {
      AppDialog.showErrorDialog(
          context, "Error: $e", () => Navigator.pop(context));
    }
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
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : NetworkImage(provider.user.imageUrl)
                                as ImageProvider,
                        child: _isUploading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : (_selectedImage == null
                                ? const Icon(Icons.person, size: 50)
                                : null),
                      ),
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
