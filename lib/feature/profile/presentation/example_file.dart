// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:dio/dio.dart';
// import 'package:path/path.dart' as path;
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
// import 'package:coyotex/core/utills/branded_primary_button.dart';
// import 'package:coyotex/core/utills/branded_text_filed.dart';
// import 'package:coyotex/utils/app_dialogue_box.dart';

// class EditProfile extends StatefulWidget {
//   const EditProfile({super.key});

//   @override
//   State<EditProfile> createState() => _EditProfileState();
// }

// class _EditProfileState extends State<EditProfile> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _mobileNumberController = TextEditingController();
//   bool isEnabled = false;
//   File? _selectedImage;

//   @override
//   void initState() {
//     super.initState();
//     final userProvider = Provider.of<UserViewModel>(context, listen: false);
//     _usernameController.text = userProvider.user.name;
//     _mobileNumberController.text = userProvider.user.number;
//     _emailController.text = userProvider.user.email;
//   }

//   // Pick image from gallery or camera
//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   // Upload profile picture
//   Future<void> _uploadProfilePicture() async {
//     if (_selectedImage == null) return;

//     final userProvider = Provider.of<UserViewModel>(context, listen: false);
//     final String userId = userProvider.user.id; // Assuming user has an ID field

//     try {
//       FormData formData = FormData.fromMap({
//         "profilePicture": await MultipartFile.fromFile(
//           _selectedImage!.path,
//           filename:path. basename(_selectedImage!.path),
//         ),
//       });

//       Dio dio = Dio();
//       Response response = await dio.post(
//         "http://44.196.64.110:5647/api/users/update-profile-picture",
//         data: formData,
//         options: Options(headers: {"Authorization": "Bearer ${userProvider.token}"}), // If token required
//       );

//       if (response.statusCode == 200) {
//       //  userProvider.updateProfilePicture(response.data["profilePictureUrl"]); // Update ViewModel
//         AppDialog.showSuccessDialog(context, "Profile picture updated!", () => Navigator.pop(context));
//       } else {
//         AppDialog.showErrorDialog(context, "Failed to update profile picture", () => Navigator.pop(context));
//       }
//     } catch (e) {
//       AppDialog.showErrorDialog(context, "Error: $e", () => Navigator.pop(context));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserViewModel>(context);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 GestureDetector(
//                   onTap: _pickImage,
//                   child: CircleAvatar(
//                     radius: 50,
//                     backgroundImage: _selectedImage != null
//                         ? FileImage(_selectedImage!)
//                         : NetworkImage(userProvider.user.) as ImageProvider,
//                     child: _selectedImage == null ? const Icon(Icons.person, size: 50) : null,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   userProvider.user.name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '@${userProvider.user.name}',
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 BrandedPrimaryButton(
//                   isEnabled: _selectedImage != null,
//                   name: "Upload Profile Picture",
//                   onPressed: _uploadProfilePicture,
//                 ),
//                 const SizedBox(height: 50),
//                 BrandedTextField(
//                   prefix: const Icon(Icons.person),
//                   controller: _usernameController,
//                   labelText: "Username",
//                   onChanged: (value) => setState(() => isEnabled = true),
//                 ),
//                 const SizedBox(height: 20),
//                 BrandedTextField(
//                   prefix: const Icon(Icons.email),
//                   controller: _emailController,
//                   labelText: "Email",
//                   isEnabled: false,
//                 ),
//                 const SizedBox(height: 20),
//                 BrandedTextField(
//                   prefix: const Icon(Icons.phone),
//                   controller: _mobileNumberController,
//                   labelText: "Mobile Number",
//                   onChanged: (value) => setState(() => isEnabled = true),
//                 ),
//                 const SizedBox(height: 30),
//                 userProvider.isLoading
//                     ? const CircularProgressIndicator()
//                     : BrandedPrimaryButton(
//                         isEnabled: isEnabled,
//                         name: "Save",
//                         onPressed: () async {
//                           var response = await userProvider.updateUserProfile(
//                             _usernameController.text,
//                             _mobileNumberController.text,
//                             userProvider.user.userPlan,
//                             userProvider.user.userWeatherPref,
//                           );

//                           if (response.success) {
//                             AppDialog.showSuccessDialog(
//                               context,
//                               response.message,
//                               () => Navigator.of(context)..pop()..pop(),
//                             );
//                           } else {
//                             AppDialog.showErrorDialog(
//                               context,
//                               response.message,
//                               () => Navigator.of(context).pop(),
//                             );
//                           }
//                         },
//                       ),
//                 const SizedBox(height: 20),
//                 BrandedPrimaryButton(
//                   isUnfocus: true,
//                   isEnabled: true,
//                   name: "Cancel",
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//                 const SizedBox(height: 100),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(home: MapScreen()));

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  GoogleMapController? _mapController;
  List<RouteModel> _routes = [];
  String _selectedRouteId = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Route Selector')),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _originController,
                    decoration: const InputDecoration(
                      labelText: 'Origin',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter origin' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Destination',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter destination' : null,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _findRoutes,
                    child: const Text('Find Routes'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(0, 0),
                    zoom: 2,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  polylines: _buildPolylines(),
                  onTap: _handleMapTap,
                ),
                if (_routes.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _RoutesList(
                      routes: _routes,
                      selectedRouteId: _selectedRouteId,
                      onRouteSelected: (id) =>
                          setState(() => _selectedRouteId = id),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Set<Polyline> _buildPolylines() {
    return _routes.map((route) {
      return Polyline(
        polylineId: PolylineId(route.id),
        points: route.points,
        color: _selectedRouteId == route.id ? Colors.blue : Colors.grey,
        width: _selectedRouteId == route.id ? 5 : 3,
      );
    }).toSet();
  }

  void _handleMapTap(LatLng tappedPoint) {
    RouteModel? closestRoute;
    double minDistance = double.infinity;

    for (final route in _routes) {
      final distance = _calculateClosestDistance(tappedPoint, route.points);
      if (distance < minDistance) {
        minDistance = distance;
        closestRoute = route;
      }
    }

    if (closestRoute != null && minDistance < 1000) {
      // 1km threshold
      setState(() => _selectedRouteId = closestRoute!.id);
    }
  }

  double _calculateClosestDistance(LatLng point, List<LatLng> polyline) {
    double minDistance = double.infinity;
    for (int i = 0; i < polyline.length - 1; i++) {
      final distance = _distanceToSegment(
        point,
        polyline[i],
        polyline[i + 1],
      );
      if (distance < minDistance) minDistance = distance;
    }
    return minDistance;
  }

  double _distanceToSegment(LatLng point, LatLng start, LatLng end) {
    const earthRadius = 6371e3; // meters
    final lat1 = start.latitude * pi / 180;
    final lon1 = start.longitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final lon2 = end.longitude * pi / 180;
    final lat3 = point.latitude * pi / 180;
    final lon3 = point.longitude * pi / 180;

    final d13 = _haversine(lat1, lon1, lat3, lon3);
    final d23 = _haversine(lat2, lon2, lat3, lon3);
    final d12 = _haversine(lat1, lon1, lat2, lon2);

    if (d12 == 0) return d13;

    final y = sin(lon2 - lon1) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);
    final bearing = atan2(y, x);
    final theta = bearing - (lon3 - lon1);

    final crossTrack = asin(sin(d13 / earthRadius) * sin(theta)) * earthRadius;
    final alongTrack =
        acos(cos(d13 / earthRadius) / cos(crossTrack / earthRadius)) *
            earthRadius;

    return alongTrack > d12 ? min(d13, d23) : crossTrack.abs();
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * atan2(sqrt(a), sqrt(1 - a)) * 6371e3;
  }

  Future<void> _findRoutes() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final origin = await _geocode(_originController.text);
      final destination = await _geocode(_destinationController.text);
      final routes = await _fetchRoutes(origin, destination);

      setState(() {
        _routes = routes;
        _selectedRouteId = routes.isNotEmpty ? routes.first.id : '';
      });

      if (routes.isNotEmpty) {
        _zoomToRoutes(origin, destination);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<LatLng> _geocode(String address) async {
    final locations = await locationFromAddress(address);
    if (locations.isEmpty) throw Exception('Location not found');
    return LatLng(locations.first.latitude!, locations.first.longitude!);
  }

  Future<List<RouteModel>> _fetchRoutes(
      LatLng origin, LatLng destination) async {
    const apiKey = 'AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'alternatives=true&key=$apiKey',
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] != 'OK')
      throw Exception(data['error_message'] ?? 'Failed to fetch routes');

    return (data['routes'] as List).map((route) {
      final points = _decodePolyline(route['overview_polyline']['points']);
      return RouteModel(
        id: route['overview_polyline']['points'],
        points: points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        distance: route['legs'][0]['distance']['text'],
        duration: route['legs'][0]['duration']['text'],
      );
    }).toList();
  }

  List<LatLng> _decodePolyline(String encoded) {
    final polyline = <LatLng>[];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  void _zoomToRoutes(LatLng origin, LatLng destination) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        min(origin.latitude, destination.latitude),
        min(origin.longitude, destination.longitude),
      ),
      northeast: LatLng(
        max(origin.latitude, destination.latitude),
        max(origin.longitude, destination.longitude),
      ),
    );
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
}

class RouteModel {
  final String id;
  final List<LatLng> points;
  final String distance;
  final String duration;

  RouteModel({
    required this.id,
    required this.points,
    required this.distance,
    required this.duration,
  });
}

class _RoutesList extends StatelessWidget {
  final List<RouteModel> routes;
  final String selectedRouteId;
  final Function(String) onRouteSelected;

  const _RoutesList({
    required this.routes,
    required this.selectedRouteId,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: routes.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final route = routes[index];
          return ListTile(
            title: Text('Route ${index + 1}'),
            subtitle: Text('${route.distance} • ${route.duration}'),
            selected: selectedRouteId == route.id,
            selectedTileColor: Colors.blue.withOpacity(0.1),
            onTap: () => onRouteSelected(route.id),
          );
        },
      ),
    );
  }
}
