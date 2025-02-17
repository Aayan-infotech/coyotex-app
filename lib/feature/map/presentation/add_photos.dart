import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({Key? key}) : super(key: key);

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _mediaFiles = []; // Holds both images and videos
  bool isLoading = false;

  Future<void> _pickMedia(BuildContext context) async {
    final action = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Media'),
          actions: <Widget>[
            TextButton(
              child: const Text('Camera (Image)'),
              onPressed: () => Navigator.of(context).pop('camera_image'),
            ),
            TextButton(
              child: const Text('Gallery (Image)'),
              onPressed: () => Navigator.of(context).pop('gallery_image'),
            ),
            TextButton(
              child: const Text('Camera (Video)'),
              onPressed: () => Navigator.of(context).pop('camera_video'),
            ),
            TextButton(
              child: const Text('Gallery (Video)'),
              onPressed: () => Navigator.of(context).pop('gallery_video'),
            ),
          ],
        );
      },
    );

    if (action != null) {
      XFile? pickedFile;
      if (action == 'camera_image') {
        pickedFile = await _picker.pickImage(source: ImageSource.camera);
      } else if (action == 'gallery_image') {
        pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      } else if (action == 'camera_video') {
        pickedFile = await _picker.pickVideo(source: ImageSource.camera);
      } else if (action == 'gallery_video') {
        pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      }

      if (pickedFile != null) {
        setState(() {
          _mediaFiles.add(File(pickedFile!.path));
        });
      }
    }
  }

  Future<void> _uploadMedia(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    final provider = Provider.of<MapProvider>(context, listen: false);
    if (_mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one photo or video')),
      );
      return;
    }

    String accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    String userId = SharedPrefUtil.getValue(userIdPref, "") as String;

    final uri = Uri.parse(
        'http://44.196.64.110:5647/api/trips/${provider.selectedTripModel.id}/upload-media');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $accessToken';

    try {
      for (final file in _mediaFiles) {
        String? mimeType = lookupMimeType(file.path);
        String field =
            mimeType?.startsWith('image') ?? false ? 'photos' : 'videos';

        final multipartFile =
            await http.MultipartFile.fromPath(field, file.path);
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        AppDialog.showSuccessDialog(context, "Media uploaded successfully", () {
          Navigator.of(context).pop();
        });
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

  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
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
                          await _uploadMedia(context);
                        }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BrandedPrimaryButton(
                        isEnabled: true,
                        isUnfocus: true,
                        name: "Finish",
                        onPressed: () async {
                          _showFinishWarningDialog(provider, context);
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
                    onTap: () {
                      _pickMedia(context);
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purple),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _mediaFiles.isEmpty
                          ? const Center(
                              child: Text(
                                "Tap to upload photo or video",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : _mediaFiles.last.path.endsWith(
                                  '.mp4') // Check if last media is video
                              ? Icon(Icons.video_library,
                                  size: 80, color: Colors.purple)
                              : Image.file(
                                  _mediaFiles.last,
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Upload photos/videos (${_mediaFiles.length}/3)",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mediaFiles.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        if (index == _mediaFiles.length) {
                          return GestureDetector(
                            onTap: () {
                              _pickMedia(context);
                            },
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
                                  image: _mediaFiles[index]
                                          .path
                                          .endsWith('.mp4')
                                      ? const AssetImage(
                                          "assets/images/video_thumbnail.png")
                                      : FileImage(_mediaFiles[index])
                                          as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeMedia(index),
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

  void _showFinishWarningDialog(
      MapProvider map_provider, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Finish Trip"),
          content: const Text("Are you sure you want to finish the trip?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                map_provider.resetFields();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("Finish"),
            ),
          ],
        );
      },
    );
  }
}
