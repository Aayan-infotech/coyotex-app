import 'package:coyotex/core/services/model/notification_model.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class AddPhotoScreen extends StatefulWidget {
  MarkerData? markerData;
  bool? isRestart;
  AddPhotoScreen({this.isRestart = false, this.markerData, Key? key})
      : super(key: key);

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _mediaFiles = [];
  bool _isUploading = false;
  bool _isInitializingVideo = false;
  VideoPlayerController? _controller;
  bool isVideo = false;
  String? selectedMarkerId;
  late ValueNotifier<double> _uploadProgressNotifier;

  int _imageCount = 0;
  int _videoCount = 0;

// Modify the _pickMedia function
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
      try {
        if (action == 'camera_image' || action == 'gallery_image') {
          // Check image limits
          if (_imageCount >= 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maximum 2 images allowed')),
            );
            return;
          }
          if (_imageCount + _videoCount >= 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maximum 3 files allowed')),
            );
            return;
          }

          pickedFile = await _picker.pickImage(
            source: action == 'camera_image'
                ? ImageSource.camera
                : ImageSource.gallery,
          );

          if (pickedFile != null) {
            setState(() {
              _mediaFiles.add(File(pickedFile!.path));
              _imageCount++;
            });
          }
        } else if (action == 'camera_video' || action == 'gallery_video') {
          // Check video limits
          if (_videoCount >= 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maximum 1 video allowed')),
            );
            return;
          }
          if (_imageCount + _videoCount >= 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maximum 3 files allowed')),
            );
            return;
          }

          pickedFile = await _picker.pickVideo(
            source: action == 'camera_video'
                ? ImageSource.camera
                : ImageSource.gallery,
          );

          if (pickedFile != null) {
            _controller?.dispose();
            setState(() {
              _mediaFiles.add(File(pickedFile!.path));
              _videoCount++;
              isVideo = true;
              _isInitializingVideo = true;
            });

            _controller = VideoPlayerController.file(File(pickedFile.path))
              ..initialize().then((_) {
                setState(() {
                  _isInitializingVideo = false;
                  _controller!.play();
                });
              }).catchError((error) {
                setState(() {
                  _isInitializingVideo = false;
                  _mediaFiles.removeLast();
                  _videoCount--;
                });
              });
          }
        }
      } finally {
        if (pickedFile == null) {
          setState(() => _isInitializingVideo = false);
        }
      }
    }
  }

// Modify the _removeMedia function
  void _removeMedia(int index) {
    final file = _mediaFiles[index];
    final isVideoFile = ['.mp4', '.mov', '.avi', '.MP4', '.MOV', '.AVI']
        .any((ext) => file.path.endsWith(ext));

    setState(() {
      if (isVideoFile) {
        _videoCount--;
        if (file == _mediaFiles.last) {
          _controller?.dispose();
          _controller = null;
          isVideo = false;
        }
      } else {
        _imageCount--;
      }
      _mediaFiles.removeAt(index);
    });
  }

  // Add this variable at the top of the _AddPhotoScreenState class
  double _uploadProgress = 0.0;

// Modify the _uploadMedia function
  // Future<void> _uploadMedia(BuildContext context) async {
  //   setState(() => _isUploading = true);
  //   _uploadProgressNotifier.value = 0.0;

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => WillPopScope(
  //       onWillPop: () async => false,
  //       child: ValueListenableBuilder<double>(
  //         valueListenable: _uploadProgressNotifier,
  //         builder: (context, progress, _) {
  //           return AlertDialog(
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 CircularProgressIndicator(
  //                     value: progress > 0 ? progress : null),
  //                 const SizedBox(height: 16),
  //                 Text("Uploading: ${(progress * 100).toStringAsFixed(0)}%"),
  //               ],
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );

  //   try {
  //     final provider = Provider.of<MapProvider>(context, listen: false);
  //     String accessToken =
  //         SharedPrefUtil.getValue(accessTokenPref, "") as String;
  //     String tripId = provider.selectedTripModel.id;
  //     String markerId = selectedMarkerId!;

  //     // Create FormData instance
  //     FormData formData = FormData();

  //     // Add media files
  //     for (File file in _mediaFiles) {
  //       String fileName = path.basename(file.path);
  //       String? fileExtension = fileName.split('.').last.toLowerCase();

  //       // Determine media type
  //       MediaType mediaType = MediaType('image', 'jpeg'); // default to image
  //       if (['mp4', 'mov', 'avi'].contains(fileExtension)) {
  //         mediaType = MediaType('video', fileExtension);
  //       } else if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
  //         mediaType = MediaType('image', fileExtension);
  //       }

  //       formData.files.add(MapEntry(
  //         'images', // Use the same field name as in your API
  //         await MultipartFile.fromFile(
  //           file.path,
  //           filename: fileName,
  //           contentType: mediaType,
  //         ),
  //       ));
  //     }

  //     // Add other form fields
  //     formData.fields.addAll([
  //       MapEntry('tripId', tripId),
  //       MapEntry('markerId', markerId),
  //     ]);

  //     final response = await Dio().post(
  //       'http://54.236.98.193:5647/api/trips/upload-media',
  //       data: formData,
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $accessToken',
  //           'Content-Type': 'multipart/form-data',
  //         },
  //       ),
  //       onSendProgress: (sent, total) {
  //         if (total != -1) {
  //           _uploadProgressNotifier.value = sent / total;
  //         }
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       final mapProvider = Provider.of<MapProvider>(context, listen: false);
  //       mapProvider.getTrips();
  //       Navigator.of(context).pop();
  //       setState(() => _isUploading = false);
  //       AppDialog.showSuccessDialog(context, "Media uploaded successfully", () {
  //         setState(() {
  //           _isUploading = false;
  //         });
  //       });
  //     } else {
  //       AppDialog.showErrorDialog(context, 'Upload failed: ${response.data}',
  //           () {
  //         Navigator.pop(context);
  //       });
  //     }
  //   } catch (e) {
  //     // ... existing error handling ...
  //     AppDialog.showErrorDialog(context, 'Upload failed: ${e.toString()}', () {
  //       Navigator.pop(context);
  //     });
  //   } finally {
  //     _uploadProgressNotifier.value = 0.0;
  //     if (mounted) {
  //       setState(() => _isUploading = false);
  //       Navigator.pop(context); // Close dialog

  //       // Close the progress dialog
  //     }
  //   }
  // }
  // Modify the _uploadMedia function as follows
  Future<void> _uploadMedia(BuildContext context) async {
    setState(() => _isUploading = true);
    _uploadProgressNotifier.value = 0.0;

    bool uploadSuccess = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: ValueListenableBuilder<double>(
          valueListenable: _uploadProgressNotifier,
          builder: (context, progress, _) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                      value: progress > 0 ? progress : null),
                  const SizedBox(height: 16),
                  Text("Uploading: ${(progress * 100).toStringAsFixed(0)}%"),
                ],
              ),
            );
          },
        ),
      ),
    );

    try {
      final provider = Provider.of<MapProvider>(context, listen: false);
      String accessToken =
          SharedPrefUtil.getValue(accessTokenPref, "") as String;
      String tripId = provider.selectedTripModel.id;
      String markerId = selectedMarkerId!;

      FormData formData = FormData();

      for (File file in _mediaFiles) {
        String fileName = path.basename(file.path);
        String? fileExtension = fileName.split('.').last.toLowerCase();

        MediaType mediaType = MediaType('image', 'jpeg');
        if (['mp4', 'mov', 'avi'].contains(fileExtension)) {
          mediaType = MediaType('video', fileExtension);
        } else if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
          mediaType = MediaType('image', fileExtension);
        }

        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: mediaType,
          ),
        ));
      }

      formData.fields.addAll([
        MapEntry('tripId', tripId),
        MapEntry('markerId', markerId),
      ]);

      final response = await Dio().post(
        'http://54.236.98.193:5647/api/trips/upload-media',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: (sent, total) {
          if (total != -1) {
            _uploadProgressNotifier.value = sent / total;
          }
        },
      );

      if (response.statusCode == 200) {
        uploadSuccess = true;
        final mapProvider = Provider.of<MapProvider>(context, listen: false);
        mapProvider.getTrips();
      } else {
        errorMessage = 'Upload failed: ${response.data}';
      }
    } catch (e) {
      errorMessage = 'Upload failed: ${e.toString()}';
    } finally {
      _uploadProgressNotifier.value = 0.0;
      if (mounted) {
        setState(() => _isUploading = false);
        //  Navigator.pop(context);
        if (widget.isRestart!) Navigator.pop(context);

        // Close progress dialog
      }

      if (uploadSuccess && mounted) {
        AppDialog.showSuccessDialog(
          context,
          "Media uploaded successfully",
          () {
            // setState(() => _isUploading = false);
            if (widget.isRestart!) {
              Navigator.of(context).pop(true);
              Navigator.of(context).pop(true);
            }
          },
        );
      } else if (errorMessage != null && mounted) {
        AppDialog.showErrorDialog(
          context,
          "Upload Failed",
          () => Navigator.pop(context),
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.markerData != null) {
      selectedMarkerId = widget.markerData!.id;
    }
    _uploadProgressNotifier = ValueNotifier(0.0);
    super.initState();
  }

  @override
  void dispose() {
    //s _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context, listen: false);
    selectedMarkerId ??= provider.selectedTripModel.markers.isNotEmpty
        ? provider.selectedTripModel.markers.first.id
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Media",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      persistentFooterButtons: _isUploading
          ? null
          : [
              Row(
                children: [
                  if (widget.markerData == null)
                    Expanded(
                      child: BrandedPrimaryButton(
                          isEnabled: true,
                          isUnfocus: true,
                          name: "Finish",
                          onPressed: () =>
                              _showFinishWarningDialog(provider, context)),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BrandedPrimaryButton(
                        isEnabled: true,
                        name: "Save",
                        onPressed:
                            _isUploading ? () {} : () => _uploadMedia(context)),
                  ),
                ],
              )
            ],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (provider.selectedTripModel.markers.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(166, 166, 166, 1)),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromRGBO(255, 255, 255, 0.2)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMarkerId,
                      hint: const Text('Select Marker'),
                      isExpanded: true,
                      dropdownColor: const Color.fromRGBO(255, 255, 255, .8),
                      onChanged: (String? newValue) =>
                          setState(() => selectedMarkerId = newValue),
                      items: provider.selectedTripModel.markers.map((marker) {
                        return DropdownMenuItem<String>(
                            value: marker.id, child: Text(marker.snippet));
                      }).toList(),
                    ),
                  ),
                )
              else
                const Text("No markers available"),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _mediaFiles.isEmpty ? () => _pickMedia(context) : null,
                child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromRGBO(166, 166, 166, 1)),
                        borderRadius: BorderRadius.circular(10)),
                    child: _mediaFiles.isEmpty
                        ? const Center(
                            child: Text("Tap to upload photo or video",
                                style: TextStyle(color: Colors.grey)))
                        : _isInitializingVideo
                            ? const Center(
                                child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text("Preparing video..."),
                                ],
                              ))
                            : isVideo
                                ? Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 18),
                                        child: AspectRatio(
                                            aspectRatio:
                                                _controller!.value.aspectRatio,
                                            child: VideoPlayer(_controller!)),
                                      ),
                                      Center(
                                        child: IconButton(
                                          icon: Icon(
                                              _controller!.value.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                              size: 50),
                                          onPressed: () => setState(() {
                                            _controller!.value.isPlaying
                                                ? _controller!.pause()
                                                : _controller!.play();
                                          }),
                                        ),
                                      )
                                    ],
                                  )
                                : Image.file(_mediaFiles.last,
                                    fit: BoxFit.cover)),
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
                                color: Color.fromRGBO(166, 166, 166, 1))),
                        const TextSpan(
                            text: "/3)",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(166, 166, 166, 1))),
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
                  itemCount: _mediaFiles.length +
                      ((_imageCount + _videoCount) < 3 ? 1 : 0),
                  // itemCount: _mediaFiles.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == _mediaFiles.length) {
                      return GestureDetector(
                        onTap: () => _pickMedia(context),
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Center(child: Icon(Icons.add)),
                        ),
                      );
                    }

                    bool isVideoFile = [
                      '.mp4',
                      '.mov',
                      '.avi',
                      '.MP4',
                      '.MOV',
                      '.AVI'
                    ].any((ext) => _mediaFiles[index].path.endsWith(ext));

                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: isVideoFile
                                  ? null
                                  : DecorationImage(
                                      image: FileImage(_mediaFiles[index]),
                                      fit: BoxFit.cover)),
                          child: isVideoFile
                              ? Center(child: Icon(Icons.videocam, size: 40))
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Center(
                            child: IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _removeMedia(index)),
                          ),
                        ),
                        if (isVideoFile && _isInitializingVideo)
                          const Center(child: CircularProgressIndicator())
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

  void _showFinishWarningDialog(MapProvider provider, BuildContext context) {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false; // Declare isLoading outside StatefulBuilder

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Finish Trip"),
              content: isLoading
                  ? const SizedBox(
                      height: 50,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const Text("Are you sure you want to finish the trip?"),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          final tripProvider = Provider.of<TripViewModel>(
                              context,
                              listen: false);

                          var response = await userProvider.sendNotifications(
                            "Trip Update",
                            "Your Trip has been Completed",
                            NotificationType.tripUpdate,
                            mapProvider.selectedTripModel.id,
                          );
                          if (response.success) {
                            var response = await tripProvider.updateUserTrip(
                                mapProvider.selectedTripModel.id);
                            if (response.success) {
                              await tripProvider.getUserTrip();
                            }
                          }

                          provider.resetFields();
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            if (widget.isRestart!) Navigator.pop(context);
                          }
                        },
                  child: const Text("Finish"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
