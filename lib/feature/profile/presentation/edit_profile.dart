import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/model/user_model.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';

class EditProfile extends StatefulWidget {
  UserModel userModel;
  EditProfile({required this.userModel, super.key});

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
  @override
  void initState() {
    // TODO: implement initState
    _usernameController.text = widget.userModel.name;
    _emailController.text = widget.userModel.email;
    _mobileNumberController.text = widget.userModel.number;

    super.initState();
  }

  // Future<void> uploadProfilePicture(BuildContext context) async {
  //   String? accessToken =
  //       SharedPrefUtil.getValue(accessTokenPref, "") as String?;
  //   _selectedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   FormData formData = FormData.fromMap({});
  //   final userProvider = Provider.of<UserViewModel>(context, listen: false);

  //   if (_selectedImage != null) {
  //     setState(() {
  //       _isUploading = true;
  //     });

  //     try {
  //       // Create FormData using Dio
  //       final fileName = _selectedImage!.path.split('/').last;
  //       final fileExtension = fileName.split('.').last;
  //       dio.MultipartFile imageFile = dio.MultipartFile.fromFileSync(
  //         _selectedImage!.path,
  //         filename: _selectedImage!.path
  //             .split('/')
  //             .last, // Extract the filename from the path
  //         contentType: MediaType("image", fileExtension),
  //       );

  //       formData.files.add(MapEntry(
  //         'profilePicture', // The field name for the image (adjust as needed)
  //         imageFile, // The image file to upload
  //       ));

  //       // Send request with Dio
  //       final response = await Dio().post(
  //         // 'http://54.236.98.193:5647/api/users/update-profile-picture',
  //         'http://54.236.98.193:5647/api/users/update-profile-picture',
  //         data: formData,
  //         options: Options(
  //           headers: {
  //             'Authorization': 'Bearer $accessToken',
  //             'Content-Type': 'multipart/form-data'
  //           },
  //         ),
  //       );

  //       if (response.statusCode == 200) {
  //         userProvider.getUser();
  //         print('Upload successful! Response: ${response.data}');
  //       } else {
  //         print('Upload failed with status: ${response.statusCode}');
  //       }
  //     } catch (e) {
  //       print('Error during upload: $e');
  //     } finally {
  //       setState(() {
  //         _isUploading = false;
  //       });
  //     }
  //   }
  // }
  Future<void> uploadProfilePicture(BuildContext context) async {
    String? accessToken =
        SharedPrefUtil.getValue(accessTokenPref, "") as String?;
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery); // Get XFile
    final userProvider = Provider.of<UserViewModel>(context, listen: false);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Convert to File
        _isUploading = true;
      });

      try {
        // Create FormData using Dio
        final fileName = _selectedImage!.path.split('/').last;
        final fileExtension = fileName.split('.').last;
        dio.MultipartFile imageFile = dio.MultipartFile.fromFileSync(
          _selectedImage!.path,
          filename: fileName,
          contentType: MediaType("image", fileExtension),
        );

        FormData formData = FormData.fromMap({
          'profilePicture': imageFile,
        });

        // Send request with Dio
        final response = await Dio().post(
          '${CallHelper.baseUrl}users/update-profile-picture',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'multipart/form-data'
            },
          ),
        );

        if (response.statusCode == 200) {
          await userProvider.getUser();
          print('Upload successful! Response: ${response.data}');
        } else {
          print('Upload failed with status: ${response.statusCode}');
        }
        setState(() {
          _isUploading = false;
        });

        // ignore: empty_catches
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Your Trips',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
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
                      onTap: () {
                        uploadProfilePicture(context);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: provider.user.imageUrl,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey,
                                        child: const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.error,
                                        color: Colors.white,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          if (_isUploading)
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                        ],
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
                                provider.user.userUnit,
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
