// import 'package:coyotex/core/services/call_halper.dart';
// import 'package:coyotex/core/utills/branded_primary_button.dart';
// import 'package:coyotex/core/utills/constant.dart';
// import 'package:coyotex/core/utills/shared_pref.dart';
// import 'package:coyotex/feature/auth/data/model/user_model.dart';
// import 'package:coyotex/feature/map/presentation/data_entry.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:dio/dio.dart' as dio;
// import 'package:image_picker/image_picker.dart';
// import 'package:http_parser/http_parser.dart';

// class AddPhotoScreen extends StatefulWidget {
//   const AddPhotoScreen({Key? key}) : super(key: key);

//   @override
//   State<AddPhotoScreen> createState() => _AddPhotoScreenState();
// }

// class _AddPhotoScreenState extends State<AddPhotoScreen> {
//   final ImagePicker _picker = ImagePicker();
//   List<File> _images = [];

//   // Future<void> _pickImage() async {
//   //   final XFile? pickedFile =
//   //       await _picker.pickImage(source: ImageSource.gallery);
//   //   if (pickedFile != null) {
//   //     setState(() {
//   //       _images.add(File(pickedFile.path));
//   //     });
//   //   }
//   // }
//   File? _image;
//   bool isLoading = false;
//   dio.MultipartFile? imageFile;
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//       try {
//         imageFile = await dio.MultipartFile.fromFile(_image!.path,
//             filename: _image!.path.split('/').last);

//         print('Image file prepared: ${imageFile!.filename}');
//       } catch (e) {
//         print('Error preparing image file: $e');
//       }
//     }
//   }

//   Future<ApiResponse> updateProfilePic(UserModel userModel) async {
//     try {
//       // Initialize the Dio client
//       dio.Dio dioClient = dio.Dio();
//       FormData formData = FormData.fromMap({});
//    String userId = SharedPrefUtil.getValue(userIdPref, "") as String;


//       // Prepare the user data as a map

//       // Prepare the FormData

//       // Check if there is a new image selected and add it to the form data
//       if (_image != null) {
//         // Prepare the image file as MultipartFile
//         final fileName = _image!.path.split('/').last;
//         final fileExtension = fileName.split('.').last;
//         dio.MultipartFile imageFile = dio.MultipartFile.fromFileSync(
//           _image!.path,
//           filename: _image!.path
//               .split('/')
//               .last, // Extract the filename from the path
//           contentType: MediaType("image", fileExtension),
//         );

//         // Add the image file to the form data with the field name expected by the server
//         formData.files.add(MapEntry(
//           'photos', // The field name for the image (adjust as needed)
//           [imageFile,imageFile], // The image file to upload
//         ));
//       }

// // print(for)
//       // Make the API call to update the user profile
//       final response = await dioClient.put(
//         'http://44.196.64.110:5647/api/trips/"${userId}"/upload-photos', // Replace with your actual API URL
//         data: formData,
//         options: dio.Options(
//           headers: {'Content-Type': 'multipart/form-data'},
//         ),
//       );

//       // Check if the response is successful (status code 200)
//       if (response.statusCode == 200) {
//         return ApiResponse(
//             response.data['message'] ?? 'Profile updated successfully', true);
//       } else {
//         return ApiResponse(
//             response.data['message'] ?? 'Error updating profile', false);
//       }
//     } catch (e) {
//       // Handle any errors that occur during the process
//       print("Error updating profile: $e");
//       return ApiResponse('An error occurred while updating profile', false);
//     }
//   }

//   void _removeImage(int index) {
//     setState(() {
//       _images.removeAt(index);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(""),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             Column(
//               children: [
//                 Image.asset(
//                   "assets/images/add_photo_icons.png",
//                   height: 100,
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   "Birds Hunt Area",
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const Text(
//                   "Lorem IpsumLorem Ipsum",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             GestureDetector(
//               onTap: _pickImage,
//               child: Container(
//                 height: 200,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.purple),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: _images.isEmpty
//                     ? const Center(
//                         child: Text(
//                           "Tap to upload photo",
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       )
//                     : Image.file(
//                         _images.last,
//                         fit: BoxFit.cover,
//                       ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text(
//                   "Upload photos/videos (${_images.length}/3)",
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             SizedBox(
//               height: 80,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: _images.length + 1,
//                 separatorBuilder: (context, index) => const SizedBox(width: 10),
//                 itemBuilder: (context, index) {
//                   if (index == _images.length) {
//                     return GestureDetector(
//                       onTap: _pickImage,
//                       child: Container(
//                         width: 80,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Center(
//                           child: Icon(Icons.add),
//                         ),
//                       ),
//                     );
//                   }
//                   return Stack(
//                     children: [
//                       Container(
//                         width: 80,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           image: DecorationImage(
//                             image: FileImage(_images[index]),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         right: 0,
//                         top: 0,
//                         child: GestureDetector(
//                           onTap: () => _removeImage(index),
//                           child: const Icon(
//                             Icons.close,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             const Spacer(),
//             BrandedPrimaryButton(
//                 isEnabled: true,
//                 name: "Save",
//                 onPressed: () {
//                   Navigator.of(context)
//                       .push(MaterialPageRoute(builder: (context) {
//                     return DataPointsScreen();
//                   }));
//                 })
//           ],
//         ),
//       ),
//     );
//   }
// }
