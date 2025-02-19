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
import 'package:video_player/video_player.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({Key? key}) : super(key: key);

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _mediaFiles = [];
  bool isLoading = false;
  VideoPlayerController? _controller;
  bool isVideo = false;
  String? selectedMarkerId;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Future<void> _pickMedia(BuildContext context) async {
  //   isVideo = false;
  //   final action = await showModalBottomSheet<String>(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (BuildContext context) {
  //       return Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text(
  //               'Select Media',
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 10),
  //             ListTile(
  //               leading: const Icon(Icons.camera_alt),
  //               title: const Text('Capture Image'),
  //               onTap: () => Navigator.of(context).pop('camera_image'),
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.photo_library),
  //               title: const Text('Pick Image from Gallery'),
  //               onTap: () => Navigator.of(context).pop('gallery_image'),
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.videocam),
  //               title: const Text('Record Video'),
  //               onTap: () => Navigator.of(context).pop('camera_video'),
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.video_library),
  //               title: const Text('Pick Video from Gallery'),
  //               onTap: () => Navigator.of(context).pop('gallery_video'),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );

  //   if (action != null) {
  //     XFile? pickedFile;
  //     if (action == 'camera_image') {
  //       isVideo = false;

  //       pickedFile = await _picker.pickImage(source: ImageSource.camera);
  //     } else if (action == 'gallery_image') {
  //       isVideo = false;

  //       pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //     } else if (action == 'camera_video') {
  //       isVideo = true;

  //       pickedFile = await _picker.pickVideo(source: ImageSource.camera);
  //       _controller?.dispose(); // Dispose the old controller
  //       if (pickedFile != null)
  //         _controller = VideoPlayerController.file(File(pickedFile!.path))
  //           ..initialize().then((_) {
  //             setState(() {}); // Refres
  //             _controller!.play(); // Auto-play the selected video
  //           });
  //     } else if (action == 'gallery_video') {
  //       isVideo = true;
  //       setState(() {});

  //       pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
  //       _controller?.dispose();
  //       if (pickedFile != null)
  //         _controller = VideoPlayerController.file(File(pickedFile!.path))
  //           ..initialize().then((_) {
  //             setState(() {}); // Refresh the UI
  //             _controller!.play(); // Auto-play the selected video
  //           });
  //     }

  //     if (pickedFile != null) {
  //       setState(() {
  //         _mediaFiles.add(File(pickedFile!.path));
  //       });
  //     }
  //   } else {}
  // }
  Future<void> _pickMedia(BuildContext context) async {
    isVideo = false;
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Media',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Capture Image'),
                onTap: () => Navigator.of(context).pop('camera_image'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick Image from Gallery'),
                onTap: () => Navigator.of(context).pop('gallery_image'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record Video'),
                onTap: () => Navigator.of(context).pop('camera_video'),
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Pick Video from Gallery'),
                onTap: () => Navigator.of(context).pop('gallery_video'),
              ),
            ],
          ),
        );
      },
    );

    if (action != null) {
      XFile? pickedFile;
      if (action == 'camera_image') {
        isVideo = false;

        pickedFile = await _picker.pickImage(source: ImageSource.camera);
      } else if (action == 'gallery_image') {
        isVideo = false;

        pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      } else if (action == 'camera_video') {
        isVideo = true;

        pickedFile = await _picker.pickVideo(source: ImageSource.camera);
        if (pickedFile != null) {
          _controller?.dispose(); // Dispose the old controller
          _controller = VideoPlayerController.file(File(pickedFile.path))
            ..initialize().then((_) {
              setState(() {
                _controller!.play(); // Auto-play the selected video
              });
            });
        }
      } else if (action == 'gallery_video') {
        isVideo = true;

        pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
        if (pickedFile != null) {
          _controller?.dispose(); // Dispose the old controller
          _controller = VideoPlayerController.file(File(pickedFile.path))
            ..initialize().then((_) {
              setState(() {
                _controller!.play(); // Auto-play the selected video
              });
            });
        }
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

    if (_mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one photo or video'),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final provider = Provider.of<MapProvider>(context, listen: false);
    if (selectedMarkerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a marker'),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    String accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    String tripId = provider.selectedTripModel.id;
    String markerId = selectedMarkerId!;

    final uri = Uri.parse('http://44.196.64.110:5647/api/trips/upload-media');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $accessToken';

    try {
      for (final file in _mediaFiles) {
        final multipartFile =
            await http.MultipartFile.fromPath('files', file.path);
        request.files.add(multipartFile);
      }

      request.fields['tripId'] = tripId;
      request.fields['markerId'] = markerId;

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

  // void _removeMedia(int index) {
  //   setState(() {
  //     _mediaFiles.removeAt(index);
  //   });
  // }
  void _removeMedia(int index) {
    setState(() {
      // Check if the file to be removed is the same as the one being played
      if (isVideo && _mediaFiles[index] == _mediaFiles.last) {
        _controller?.pause();
        _controller?.dispose();
        _controller = null; // Clear the controller to prevent further usage
        isVideo = false; // Reset the isVideo flag
      }
      _mediaFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context, listen: false);

    if (selectedMarkerId == null &&
        provider.selectedTripModel.markers.isNotEmpty) {
      selectedMarkerId = provider.selectedTripModel.markers.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        forceMaterialTransparency: true,
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
                        isUnfocus: true,
                        name: "Finish",
                        onPressed: () async {
                          _showFinishWarningDialog(provider, context);
                        }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BrandedPrimaryButton(
                        isEnabled: true,
                        name: "Save",
                        onPressed: () async {
                          await _uploadMedia(context);
                        }),
                  ),
                ],
              )
            ],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Column(
                    //   children: [
                    //     Image.asset(
                    //       "assets/images/add_photo_icons.png",
                    //       height: 70,
                    //     ),
                    //     const SizedBox(height: 8),
                    //     const Text(
                    //       "Birds Hunt Area",
                    //       style: TextStyle(
                    //           fontSize: 24, fontWeight: FontWeight.bold),
                    //     ),
                    //     const Text(
                    //       "Lorem IpsumLorem Ipsum",
                    //       style: TextStyle(fontSize: 16, color: Colors.grey),
                    //     ),
                    //   ],
                    // ),
                    //  const SizedBox(height: 20),
                    // Dropdown for selecting marker
                    if (provider.selectedTripModel.markers.isNotEmpty)
                      Container(
                        width: double.infinity, // Full width
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12), // Padding for inner content
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromRGBO(166, 166, 166, 1),
                              width: 1), // All-side border
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // Background color
                        ),
                        child: DropdownButtonHideUnderline(
                          // Hide default underline
                          child: DropdownButton<String>(
                            value: selectedMarkerId,
                            hint: const Text('Select Marker'),
                            isExpanded:
                                true, // Makes it take full width of the container
                            dropdownColor: Color.fromRGBO(
                                255, 255, 255, .8), // Fill color for dropdown
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedMarkerId = newValue;
                              });
                            },
                            items: provider.selectedTripModel.markers
                                .map((marker) {
                              return DropdownMenuItem<String>(
                                value: marker.id,
                                child: Text(marker.snippet),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    else
                      const Text("No markers available"),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _mediaFiles.isEmpty
                          ? () {
                              _pickMedia(context);
                            }
                          : null,
                      child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromRGBO(166, 166, 166, 1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _mediaFiles.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Tap to upload photo or video",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : isVideo
                                  ? Stack(
                                      children: [
                                        Center(
                                          child: AspectRatio(
                                            aspectRatio:
                                                _controller!.value.aspectRatio,
                                            child: VideoPlayer(_controller!),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (_controller != null &&
                                                _controller!.value.isPlaying) {
                                              _controller!.pause();
                                              setState(() {});
                                              // Pause the video if it's playing
                                            } else if (_controller != null) {
                                              _controller!.play();
                                              setState(() {});
                                              // Play the video if it's paused
                                            }
                                          },
                                          child: Center(
                                            child: Icon(
                                              _controller?.value.isPlaying ==
                                                      true
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : ClipRect(
                                      child: Align(
                                        //  alignment: Alignment.center,
                                        // widthFactor: 1.0,
                                        // heightFactor: 1.0,
                                        child: Image.file(
                                          _mediaFiles.last,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Upload photos/videos ",
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(55, 65, 81, 1),
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: "(${_mediaFiles.length}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(166, 166, 166, 1),
                                ),
                              ),
                              TextSpan(
                                text: "/3)",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(166, 166, 166, 1),
                                ),
                              ),
                            ],
                          ),
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
                            // This is the 'add media' button
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

                          // Determine if the current file is a video
                          bool isVideoFile =
                              _mediaFiles[index].path.endsWith('.mp4') ||
                                  _mediaFiles[index].path.endsWith('.mov') ||
                                  _mediaFiles[index].path.endsWith('.avi') ||
                                  _mediaFiles[index].path.endsWith('.MP4') ||
                                  _mediaFiles[index].path.endsWith('.MOV') ||
                                  _mediaFiles[index].path.endsWith('.avi');
                          print(isVideo);

                          return Stack(
                            children: [
                              // Handle video and image cases
                              isVideoFile
                                  ? Container(
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // image: DecorationImage(
                                        //   image: AssetImage(
                                        //       'assets/images/video.png'),
                                        //   fit: BoxFit.cover,
                                        // ),
                                      ),
                                      child: Center(
                                          child: Image.asset(
                                              "assets/images/video.png")),
                                    )
                                  : Container(
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: FileImage(_mediaFiles[index])
                                              as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () => _removeMedia(index),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
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

  // ... [Existing _showFinishWarningDialog and other methods] ...
}
