import 'package:coyotex/core/services/model/notification_model.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AddPhotoScreen extends StatefulWidget {
  MarkerData? markerData;
  AddPhotoScreen({this.markerData, Key? key}) : super(key: key);

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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

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
  //       if (pickedFile != null) {
  //         _controller?.dispose(); // Dispose the old controller
  //         _controller = VideoPlayerController.file(File(pickedFile.path))
  //           ..initialize().then((_) {
  //             setState(() {
  //               _controller!.play(); // Auto-play the selected video
  //             });
  //           });
  //       }
  //     } else if (action == 'gallery_video') {
  //       isVideo = true;

  //       pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
  //       if (pickedFile != null) {
  //         _controller?.dispose(); // Dispose the old controller
  //         _controller = VideoPlayerController.file(File(pickedFile.path))
  //           ..initialize().then((_) {
  //             setState(() {
  //               _controller!.play(); // Auto-play the selected video
  //             });
  //           });
  //       }
  //     }

  //     if (pickedFile != null) {
  //       setState(() {
  //         _mediaFiles.add(File(pickedFile!.path));
  //       });
  //     }
  //   }
  // }

  Future<void> _uploadMedia(BuildContext context) async {
    setState(() => _isUploading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Uploading media... Please wait"),
            ],
          ),
        ),
      ),
    );

    if (_mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one photo or video')),
      );
      setState(() => _isUploading = false);
      Navigator.pop(context);
      return;
    }

    final provider = Provider.of<MapProvider>(context, listen: false);
    if (selectedMarkerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a marker')),
      );
      setState(() => _isUploading = false);
      Navigator.pop(context);
      return;
    }

    try {
      String accessToken =
          SharedPrefUtil.getValue(accessTokenPref, "") as String;
      String tripId = provider.selectedTripModel.id;
      String markerId = selectedMarkerId!;

      final uri = Uri.parse('http://54.236.98.193:5647/api/trips/upload-media');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $accessToken';

      for (final file in _mediaFiles) {
        request.files
            .add(await http.MultipartFile.fromPath('files', file.path));
      }

      request.fields['tripId'] = tripId;
      request.fields['markerId'] = markerId;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final mapProvider = Provider.of<MapProvider>(context, listen: false);
        await mapProvider.getTrips();
        setState(() => _isUploading = false);
        AppDialog.showSuccessDialog(context, "Media uploaded successfully",
            () async {
          Navigator.popUntil(context, (route) => route.isFirst);
        });
        setState(() => _isUploading = false);
      } else {
        AppDialog.showErrorDialog(context, 'Upload failed: $responseBody', () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      AppDialog.showErrorDialog(context, 'Upload failed: ${e.toString()}', () {
        Navigator.pop(context);
      });
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.markerData != null) {
      selectedMarkerId = widget.markerData!.id;
    }
    super.initState();
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
    final userProvider=Provider.of<UserViewModel>(context,listen: false);
    final mapProvider=Provider.of<MapProvider>(context,listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Finish Trip"),
        content: const Text("Are you sure you want to finish the trip?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () async{
                NotificationModel notification=NotificationModel(id: '', userId: '', title: "Trip Update", body: "Your trip has been completed ", type: NotificationType.tripUpdate, data: {}, isRead: false, createdAt: DateTime.now().toString(), v: 1);
              await  userProvider.sendNotifications( "Trip Update","Your Trip has been Completed" ,NotificationType.tripUpdate,mapProvider.selectedTripModel.id);
                provider.resetFields();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Finish")),
        ],
      ),
    );
  }
}
