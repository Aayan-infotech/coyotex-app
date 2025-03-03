// import 'dart:convert';
// import 'dart:convert';
// import 'dart:math';
// import 'package:coyotex/core/services/model/weather_model.dart';
// import 'package:coyotex/core/services/server_calls/trip_apis.dart';
// import 'package:coyotex/utils/app_dialogue_box.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:uuid/uuid.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import '../data/trip_model.dart';
// import 'package:geocoding/geocoding.dart';
//
// class MapProvider with ChangeNotifier {
//   final TextEditingController startController = TextEditingController();
//    TextEditingController destinationController = TextEditingController();
//   final List<TextEditingController> destinationControllers = [];
//   int destinationCount = 1;
//   final List<TripModel> trips = [];
//   bool isTap = true;
//   final Set<Polyline> polylines = {};
//   final Set<Marker> markers = {};
//
//   List<LatLng> points = [];
//   final String sessionToken = const Uuid().v4();
//   var kGoogleApiKey = "AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s";
//   String markerId = '';
//   List<dynamic> startSuggestions = [];
//   List<dynamic> destinationSuggestions = [];
//   GoogleMapController? mapController;
//   LatLng initialPosition = const LatLng(26.862421770613125, 80.99804357972356);
//    int timeDurations = 0;
//   LatLng? pointA;
//   LatLng? pointB;
//   bool isSave = false;
//   bool onTapOnMap = false;
//   bool isLoading = false;
//   double distance = 0.0;
//   bool isTripStart = false;
//   bool isHurryUp = false;
//   bool isSavedTrip = false;
//   bool isKeyDataPoint = false;
//   bool isStartSuggestions = false;
//
//   late BitmapDescriptor _markerIcon;
//   TripAPIs _tripAPIs = TripAPIs();
//   late WeatherResponse weather = defaultWeatherResponse;
//   final String apiKey = "AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s";
//
//   Future<void> getWeather(LatLng latAndLng) async {
//     isLoading = true;
//     var response =
//         await _tripAPIs.getWeather(latAndLng.latitude, latAndLng.longitude);
//     weather = WeatherResponse.fromJson(response);
//     isLoading = false;
//   }
//
//   Future<void> getCurrentLocation() async {
//     isLoading = true;
//     try {
//       // Check if location services are enabled
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw Exception('Location services are disabled.');
//       }
//
//       // Check and request location permission
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception('Location permissions are denied.');
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         throw Exception('Location permissions are permanently denied.');
//       }
//
//       // Get the current position
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       // Update initial position with the retrieved coordinates
//       initialPosition = LatLng(position.latitude, position.longitude);
//       await getWeather(initialPosition);
//       isLoading = false;
//
//       notifyListeners();
//     } catch (e) {
//       debugPrint("Error getting current location: $e");
//     }
//   }
//
//   /// Load custom live location icon
//   void loadCustomLiveLocationIcon() async {
//     _markerIcon = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(100, 100)),
//       'assets/images/marker_icon.png',
//     );
//   }
//
//   void increaseCount() {
//     destinationCount += destinationCount;
//     TextEditingController _textController = TextEditingController();
//     destinationControllers.add(_textController);
//     notifyListeners();
//   }
//
//   void letsHunt() async {
//     isTripStart = true;
//     isSave = false;
//     isLoading = true;
//     onTapOnMap = false;
//     // isTap = false;
//
//     notifyListeners();
//     try {
//       // Request location permissions
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw Exception('Location services are disabled.');
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception('Location permissions are denied.');
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         throw Exception('Location permissions are permanently denied.');
//       }
//
//       // Get the initial location and fetch the route
//       Position initialPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       print(
//           'Initial location: ${initialPosition.latitude}, ${initialPosition.longitude}');
//       path.add(LatLng(initialPosition.latitude, initialPosition.longitude));
//
//       // Fetch the route only once
//       await fetchRouteWithWaypoints(path);
//       isLoading = false;
//
//       // Start listening to location updates for the user pointer
//       Geolocator.getPositionStream(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 0, // Trigger updates regardless of distance
//         ),
//       ).listen((Position position) {
//         if (position != null) {
//           print(
//               'Updated location: ${position.latitude}, ${position.longitude}');
//           notifyListeners();
//         }
//       });
//     } catch (e) {
//       isLoading = false;
//       notifyListeners();
//       print('Error: $e');
//     }
//   }
//
//   void addStop() async {
//     try {
//       isLoading = true; // Indicate loading state
//       isHurryUp = true;
//       isKeyDataPoint = false;
//       isTripStart = false;
//
//       notifyListeners();
//
//       // Fetch the user's current location
//       Position currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       LatLng currentStop =
//           LatLng(currentPosition.latitude, currentPosition.longitude);
//
//       // Add the current location as a new stop in the path
//       points.add(currentStop);
//       path.add(currentStop);
//
//       // Update the list of markers
//       final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
//       markerId = uniqueId;
//       markers.add(Marker(
//         markerId: MarkerId(uniqueId),
//         position: currentStop,
//         // // // icon: _markerIcon,
//         infoWindow: InfoWindow(
//           title: 'Stop ${points.length}',
//           snippet: '${currentStop.latitude}, ${currentStop.longitude}',
//         ),
//       ));
//
//       // Add a new destination controller for the stop
//       // TextEditingController stopController = TextEditingController(
//       //   text: '${currentStop.latitude}, ${currentStop.longitude}',
//       // );
//       // destinationControllers.add(stopController);
//
//       // Fetch and redraw the updated route
//       await fetchRouteWithWaypoints(path);
//
//       // Recalculate the total distance
//       distance = _calculateTotalDistance();
//       isSave = false;
//     } catch (e) {
//       debugPrint("Error while adding a stop: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   void hurryUp() {
//     isTripStart = false;
//     isSave = false;
//     isHurryUp = false;
//     isKeyDataPoint = true;
//     notifyListeners();
//   }
//
//   void submit(BuildContext context) {
//     isTripStart = false;
//     isSave = false;
//     isHurryUp = false;
//     isKeyDataPoint = false;
//     resetFields();
//     Navigator.of(context).pop();
//     notifyListeners();
//   }
//
//   Future<void> drawPolylineWithMarkers(TripModel trip) async {
//     // Clear existing markers and polylines
//     isLoading = true;
//     isSave = true;
//     notifyListeners();
//     markers.clear();
//     polylines.clear();
//
//     // Add markers from the trip's MarkerData
//     for (var markerData in trip.markers) {
//       markers.add(
//         Marker(
//           markerId: MarkerId(markerData.id),
//           position: markerData.position,
//           // // // icon: _markerIcon,
//           infoWindow: InfoWindow(
//             title: markerData.title,
//             snippet: markerData.snippet,
//           ),
//         ),
//       );
//     }
//
//     // Draw polyline from routePoints in the trip
//     polylines.add(
//       Polyline(
//         polylineId: PolylineId("route"),
//         points: trip.routePoints, // Use routePoints from the TripModel
//         color: Colors.blue,
//         width: 5,
//       ),
//     );
//     points = trip.routePoints;
//
//     distance = _calculateTotalDistance();
//     // Optionally, add start and end markers with special titles
//     if (trip.routePoints.isNotEmpty) {
//       var start = trip.routePoints.first;
//       var end = trip.routePoints.last;
//
//       markers.add(
//         Marker(
//           markerId: MarkerId("start"),
//           // // icon: _markerIcon,
//           position: start,
//           infoWindow: InfoWindow(title: "Start"),
//         ),
//       );
//
//       markers.add(
//         Marker(
//           markerId: MarkerId("end"),
//           position: end,
//           // // icon: _markerIcon,
//           infoWindow: InfoWindow(title: "End"),
//         ),
//       );
//     }
//     isLoading = false;
//
//     notifyListeners();
//   }
//
//   void saveTrip(BuildContext context) async {
//     isLoading = true;
//     notifyListeners();
//     if (points.isEmpty) {
//       debugPrint("Cannot save trip. Please ensure all fields are filled.");
//       return;
//     }
//
//     final trip = TripModel(
//       id: const Uuid().v4(),
//       name: 'Trip ${trips.length + 1}',
//       startLocation: startController.text,
//       destination: destinationController.text,
//       waypoints: destinationControllers.map((c) => c.text).toList(),
//       totalDistance: distance,
//       createdAt: DateTime.now(),
//       routePoints: List.from(points),
//       markers: markers.map((marker) {
//         return MarkerData(
//           id: marker.markerId.value,
//           position: marker.position,
//           title: marker.infoWindow.title ?? '',
//           snippet: marker.infoWindow.snippet ?? '',
//           duration: timeDurations,
//           markerType: "Start"
//         );
//       }).toList(),
//
//     );
//
//     var res = await _tripAPIs.addTrip(trip);
//     if (res.success) {
//       print(res);
//       trips.add(trip);
//       resetFields();
//     } else {
//       AppDialog.showErrorDialog(context, res.message, () {
//         Navigator.of(context).pop();
//       });
//     }
//     isLoading = false;
//     notifyListeners();
//   }
//
//   // Reset input fields and points
//   void resetFields() {
//     startController.clear();
//     destinationController.clear();
//     destinationControllers.clear();
//     points.clear();
//     path.clear();
//     polylines.clear();
//     markers.clear();
//     onTapOnMap = false;
//     isSave = false;
//     distance = 0.0;
//     notifyListeners();
//   }
//
//   Future<void> setTimeDuration( int duration) async {
//     timeDurations = duration;
//     notifyListeners();
//   }
//
//   Future<void> initLocationService() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//     } catch (e) {
//       debugPrint("Error while requesting location permission: $e");
//     }
//   }
//
//   Future<void> fetchRouteWithWaypoints(List<LatLng> locations,
//       {bool isRemove = false}) async {
//     if (locations.isEmpty || (locations.length < 2 && !isRemove)) {
//       debugPrint("At least two locations are required.");
//       return;
//     }
//
//     if (locations.length == 1) {
//       locations.add((locations.first));
//     }
//     isLoading = true;
//     notifyListeners();
//
//     try {
//       // Convert the LatLng locations to a string of waypoints
//       String waypoints = locations
//           .skip(1) // Skip the first point, as it's the origin
//           .map((location) => '${location.latitude},${location.longitude}')
//           .join('|'); // Join with a '|' to separate the points
//
//       // Include `optimize:true` to get the shortest path and `alternatives=true` for multiple routes
//       final url =
//           'https://maps.googleapis.com/maps/api/directions/json?origin=${locations.first.latitude},${locations.first.longitude}&destination=${locations.last.latitude},${locations.last.longitude}&waypoints=$waypoints&mode=driving&alternatives=true&key=$apiKey';
//
//       final response = await http.get(Uri.parse(url));
//       final data = jsonDecode(response.body);
//
//       if (data['status'] == 'OK') {
//         polylines.clear(); // Clear existing polylines
//
//         // Iterate through all the routes provided by the API
//         for (int i = 0; i < data['routes'].length; i++) {
//           final route = data['routes'][i];
//           final encodedPolyline = route['overview_polyline']['points'];
//           final polylinePoints = _decodePolyline(encodedPolyline);
//
//           // Add the polyline for the route
//           polylines.add(Polyline(
//             polylineId: PolylineId('route_$i'),
//             points: polylinePoints,
//             color: Colors.blue.withOpacity((i + 1) /
//                 data['routes'].length), // Different opacity for each route
//             width: 5,
//           ));
//
//           // Optionally log optimized waypoint order for each route
//           if (route['waypoint_order'] != null) {
//             debugPrint(
//                 "Route $i optimized waypoint order: ${route['waypoint_order']}");
//           }
//         }
//
//         // Adjust the map camera to fit the first route (or the most optimal route)
//         if (polylines.isNotEmpty && mapController != null) {
//           LatLngBounds bounds = _getLatLngBounds(polylines.first.points);
//           mapController
//               ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//         }
//
//         debugPrint("Successfully fetched ${data['routes'].length} routes.");
//       } else {
//         debugPrint(
//             "Error: ${data['status']} - ${data['error_message'] ?? 'No details provided'}");
//       }
//     } catch (e) {
//       debugPrint("Error fetching routes: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> getPlaceSuggestions(String input, bool isStartField) async {
//     isStartSuggestions = true;
//     if (input.isEmpty) {
//       if (isStartField) {
//         startSuggestions = [];
//       } else {
//         destinationSuggestions = [];
//       }
//
//       return;
//     }
//
//     try {
//       final url =
//           'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$kGoogleApiKey&sessiontoken=$sessionToken';
//       final response = await http.get(Uri.parse(url));
//       final data = jsonDecode(response.body);
//
//       if (isStartField) {
//         startSuggestions = data['predictions'] ?? [];
//       } else {
//         destinationSuggestions = data['predictions'] ?? [];
//       }
//     } catch (e) {
//       debugPrint("Error while fetching suggestions: $e");
//     }
//     notifyListeners();
//   }
//
//   Future<void> drawPolyline() async {
//     if (points.length > 1) {
//       polylines.clear();
//       polylines.add(Polyline(
//         polylineId: const PolylineId('route'),
//         points: points,
//         color: Colors.blue,
//         width: 5,
//       ));
//       adjustCameraBounds();
//       notifyListeners();
//     }
//   }
//
//   void adjustCameraBounds() {
//     if (points.isNotEmpty && mapController != null) {
//       LatLngBounds bounds = _getLatLngBounds(points);
//       mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//     }
//   }
//
//   double _calculateTotalDistance() {
//     double totalDistance = 0.0;
//     for (int i = 0; i < points.length - 1; i++) {
//       totalDistance += Geolocator.distanceBetween(
//         points[i].latitude,
//         points[i].longitude,
//         points[i + 1].latitude,
//         points[i + 1].longitude,
//       );
//     }
//     totalDistance = totalDistance / 1000;
//     return totalDistance;
//   }
//
//   LatLngBounds _getLatLngBounds(List<LatLng> points) {
//     double? minLat, maxLat, minLng, maxLng;
//
//     for (LatLng point in points) {
//       if (minLat == null || point.latitude < minLat) minLat = point.latitude;
//       if (maxLat == null || point.latitude > maxLat) maxLat = point.latitude;
//       if (minLng == null || point.longitude < minLng) minLng = point.longitude;
//       if (maxLng == null || point.longitude > maxLng) maxLng = point.longitude;
//     }
//
//     return LatLngBounds(
//       southwest: LatLng(minLat!, minLng!),
//       northeast: LatLng(maxLat!, maxLng!),
//     );
//   }
//
//   List<LatLng> _decodePolyline(String encoded) {
//     final polyline = <LatLng>[];
//     int index = 0, len = encoded.length;
//     int lat = 0, lng = 0;
//
//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;
//
//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;
//
//       polyline.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//
//     return polyline;
//   }
//
//   String start = '';
//   String end = '';
//   Future<void> onSuggestionSelected(String placeId, bool isStartField,
//       TextEditingController _controller) async {
//     final url =
//         'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey';
//
//     try {
//       final response = await http.get(Uri.parse(url));
//       final data = jsonDecode(response.body);
//
//       if (data['status'] == 'OK') {
//         final location = data['result']['geometry']['location'];
//         final latAndLng = LatLng(location['lat'], location['lng']);
//         _controller.text = data['result']['formatted_address'];
//         if (isStartField) {
//           startController.text = data['result']['formatted_address'];
//
//           TextEditingController _1stController = TextEditingController();
//           destinationControllers.add((_1stController));
//           // pointA = latAndLng;
//           // markerId = 'start';
//         } else {
//           // destinationController.text = data['result']['formatted_address'];
//           destinationControllers.last.text =
//               data['result']['formatted_address'];
//           // pointB = latAndLng;
//           // markerId = 'destination';
//         }
//         points.add(latAndLng);
//         path.add(latAndLng);
//
//         if (points.length >= 2) {
//           distance = _calculateTotalDistance();
//           isSave = true;
//           isHurryUp = false;
//           isKeyDataPoint = false;
//           isTripStart = false;
//         }
//
//         final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
//         markerId = uniqueId;
//         markers.add(Marker(
//           markerId: MarkerId(uniqueId),
//           // // icon: _markerIcon,
//           position: latAndLng,
//           infoWindow: InfoWindow(
//             title: 'Point ${points.length}',
//             snippet: '${latAndLng.latitude}, ${latAndLng.longitude}',
//           ),
//         ));
//
//         if (points.isNotEmpty) {
//           initialPosition = LatLng(points[0].latitude, points[0].longitude);
//         }
//
//         await fetchRouteWithWaypoints(
//           path,
//         );
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint("Error fetching place details: $e");
//     }
//   }
//
//   List<LatLng> path = [];
//   // void onMapTapped(LatLng position) async {
//   //   isLoading = true;
//   //   isSavedTrip = false;
//
//   //   points.add(position);
//   //   path.add(position);
//   //   if (points.length == 1) {
//   //     // startController.text = "${position.latitude}, ${position.longitude}";
//   //   } else {
//   //     final controller = TextEditingController(
//   //       text: "${position.latitude}, ${position.longitude}",
//   //     );
//   //     destinationControllers.add(controller);
//   //   }
//
//   //   if (points.length >= 2) {
//   //     distance = _calculateTotalDistance();
//   //     isSave = true;
//   //     isHurryUp = false;
//   //     isKeyDataPoint = false;
//   //     isTripStart = false;
//   //   }
//   //   final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
//   //   markerId = uniqueId;
//
//   //   markers.add(Marker(
//   //     markerId: MarkerId(uniqueId),
//   //     // // icon: _markerIcon,
//   //     position: position,
//   //     infoWindow: InfoWindow(
//   //       title: 'Point ${points.length}',
//   //       snippet: '${position.latitude}, ${position.longitude}',
//   //     ),
//   //   ));
//   //   if (points.length >= 2) {
//   //     await fetchRouteWithWaypoints(path);
//   //   }
//   //   isLoading = false;
//   //   // drawPolyline();
//   //   notifyListeners();
//   // }
//
//   void onMapTapped(LatLng position) async {
//     isLoading = true;
//     isSavedTrip = false;
//     onTapOnMap = true;
//
//     points.add(position);
//     path.add(position);
//
//     // Fetch location name
//     String locationName = await _getLocationName(position);
//
//     if (points.length == 1) {
//        startController.text = locationName;
//     } else {
//       final controller = TextEditingController(text: locationName);
//       destinationControllers.add(controller);
//       destinationController =  controller;
//     }
//
//     if (points.length >= 2) {
//       distance = _calculateTotalDistance();
//       isSave = true;
//       isHurryUp = false;
//       isKeyDataPoint = false;
//       isTripStart = false;
//     }
//
//     final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
//     markerId = uniqueId;
//
//     markers.add(Marker(
//       markerId: MarkerId(uniqueId),
//       position: position,
//       infoWindow: InfoWindow(
//         title: 'Point ${points.length}',
//         snippet: locationName,
//       ),
//     ));
//
//     if (points.length >= 2) {
//       await fetchRouteWithWaypoints(path);
//     }
//
//     isLoading = false;
//     notifyListeners();
//   }
//
//   Future<String> _getLocationName(LatLng position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks.first;
//         return "${place.name}, ${place.locality}, ${place.country}";
//       }
//     } catch (e) {
//       print("Error fetching location name: $e");
//     }
//     return "Unknown Location";
//   }
//
//   void onRemove(LatLng position) async {
//     isLoading = true;
//     notifyListeners();
//
//     points.remove(position);
//     path.remove(position);
//
//     markers.removeWhere((marker) => marker.position == position);
//
//     destinationControllers.removeWhere(
//       (controller) =>
//           controller.text == "${position.latitude}, ${position.longitude}",
//     );
//
//     if (points.isEmpty) {
//       isSave = false;
//       isHurryUp = false;
//       isKeyDataPoint = false;
//       isTripStart = false;
//       distance = 0.0;
//     } else if (points.length >= 2) {
//       distance = _calculateTotalDistance();
//     }
//     await fetchRouteWithWaypoints(path, isRemove: true);
//
//     isLoading = false;
//     notifyListeners();
//   }
// }
