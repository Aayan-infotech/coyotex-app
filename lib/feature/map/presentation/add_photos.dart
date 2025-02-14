import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/map/presentation/data_entry.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({Key? key}) : super(key: key);

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  bool isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _uploadPhotos() async {
    setState(() {
      isLoading = true;
    });
    final provider = Provider.of<MapProvider>(context, listen: false);
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one photo')),
      );
      return;
    }
    String accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    String userId = SharedPrefUtil.getValue(userIdPref, "") as String;

    final uri = Uri.parse(
        'http://44.196.64.110:5647/api/trips/${provider.selectedTripModel.id}/upload-photos');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer ${accessToken}';

    try {
      // Add all selected images to the request
      for (final image in _images) {
        final multipartFile =
            await http.MultipartFile.fromPath('photos', image.path);
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        AppDialog.showSuccessDialog(
            context, "Photos/Videos uploaded successfully", () {
          Navigator.of(context).pop();
        });
        // Navigate to next screen on success
        // if (!mounted) return;
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => DataPointsScreen(
        //             id: provider.selectedTripModel.id,
        //           )),
        // );
      } else {
        if (!mounted) return;
        AppDialog.showErrorDialog(context, 'Upload failed: $responseBody', () {
          Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (!mounted) return;
      AppDialog.showErrorDialog(context, 'Upload failed.', () {
        Navigator.of(context).pop();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      persistentFooterButtons: isLoading
          ? null
          : [
              Row(
                children: [
                  Expanded(
                    child: BrandedPrimaryButton(
                        isEnabled: true,
                        name: "Save",
                        onPressed: () async {
                          await _uploadPhotos();
                        }),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: BrandedPrimaryButton(
                        isEnabled: true,
                        isUnfocus: true,
                        name: "Finish",
                        onPressed: () async {
                          _showFinishWarningDialog(provider);
                        }),
                  ),
                ],
              )
            ],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // const SizedBox(height: 20),
                  Column(
                    children: [
                      Image.asset(
                        "assets/images/add_photo_icons.png",
                        height: 70,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Birds Hunt Area",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Lorem IpsumLorem Ipsum",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purple),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _images.isEmpty
                          ? const Center(
                              child: Text(
                                "Tap to upload photo",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : Image.file(
                              _images.last,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Upload photos/videos (${_images.length}/3)",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        if (index == _images.length) {
                          return GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(Icons.add),
                              ),
                            ),
                          );
                        }
                        return Stack(
                          children: [
                            Container(
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(_images[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showFinishWarningDialog(MapProvider map_provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Finish Trip"),
          content: const Text("Are you sure you want to finish the trip?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                map_provider.resetFields();
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Finish"),
            ),
          ],
        );
      },
    );
  }
}
