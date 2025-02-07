// import 'dart:convert';
// import 'dart:math';
// import 'package:coyotex/core/services/model/weather_model.dart';
// import 'package:coyotex/core/services/server_calls/trip_apis.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:uuid/uuid.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import '../data/trip_model.dart';
//
// class MapProvider with ChangeNotifier {
//   final TextEditingController startController = TextEditingController();
//   final List<TextEditingController> destinationControllers = [];
//   final List<TripModel> trips = [];
//   final Set<Polyline> polylines = {};
//   final Set<Marker> markers = {};
//   List<LatLng> points = [];
//   List<LatLng> path = [];
//
//   final String sessionToken = const Uuid().v4();
//   final String apiKey = "AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s";
//   String markerId = '';
//
//   List<dynamic> startSuggestions = [];
//   List<dynamic> destinationSuggestions = [];
//   GoogleMapController? mapController;
//   LatLng initialPosition = const LatLng(26.862421770613125, 80.99804357972356);
//   final Map<String, Duration> timeDurations = {};
//   bool isLoading = false;
//   double distance = 0.0;
//   bool isTripStart = false;
//   bool isHurryUp = false;
//   bool isSavedTrip = false;
//   bool isKeyDataPoint = false;
//   bool isStartSuggestions = false;
//   late BitmapDescriptor _markerIcon;
//   TripAPIs _tripAPIs = TripAPIs();
//   late WeatherResponse weather = defaultWeatherResponse;
//
//   // Helper method to check and request location permissions
//   Future<void> _checkLocationPermissions() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) throw Exception('Location services are disabled.');
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw Exception('Location permissions are denied.');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       throw Exception('Location permissions are permanently denied.');
//     }
//   }
//
//   // Fetch weather data for a given LatLng
//   Future<void> getWeather(LatLng latAndLng) async {
//     isLoading = true;
//     notifyListeners();
//     try {
//       var response = await _tripAPIs.getWeather(latAndLng.latitude, latAndLng.longitude);
//       weather = WeatherResponse.fromJson(response);
//     } catch (e) {
//       debugPrint("Error fetching weather: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Get the current location and update initialPosition
//   Future<void> getCurrentLocation() async {
//     isLoading = true;
//     notifyListeners();
//     try {
//       await _checkLocationPermissions();
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       initialPosition = LatLng(position.latitude, position.longitude);
//       await getWeather(initialPosition);
//     } catch (e) {
//       debugPrint("Error getting current location: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Load custom marker icon
//   void loadCustomLiveLocationIcon() async {
//     _markerIcon = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(100, 100)),
//       'assets/images/marker_icon.png',
//     );
//   }
//
//   // Add a new stop to the trip
//   void addStop() async {
//     isLoading = true;
//     isHurryUp = true;
//     isKeyDataPoint = false;
//     isTripStart = false;
//     notifyListeners();
//
//     try {
//       Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       LatLng currentStop = LatLng(currentPosition.latitude, currentPosition.longitude);
//
//       points.add(currentStop);
//       path.add(currentStop);
//
//       final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
//       markerId = uniqueId;
//       markers.add(Marker(
//         markerId: MarkerId(uniqueId),
//         position: currentStop,
//         infoWindow: InfoWindow(
//           title: 'Stop ${points.length}',
//           snippet: '${currentStop.latitude}, ${currentStop.longitude}',
//         ),
//       ));
//
//       await fetchRouteWithWaypoints(path);
//       distance = _calculateTotalDistance();
//     } catch (e) {
//       debugPrint("Error adding stop: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Fetch route with waypoints from Google Maps API
//   Future<void> fetchRouteWithWaypoints(List<LatLng> locations) async {
//     if (locations.length < 2) {
//       debugPrint("At least two locations are required.");
//       return;
//     }
//
//     isLoading = true;
//     notifyListeners();
//
//     try {
//       String waypoints = locations.skip(1).map((location) => '${location.latitude},${location.longitude}').join('|');
//       final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${locations.first.latitude},${locations.first.longitude}&destination=${locations.last.latitude},${locations.last.longitude}&waypoints=optimize:true|$waypoints&mode=driving&avoid=highways&alternatives=true&key=$apiKey';
//
//       final response = await http.get(Uri.parse(url));
//       final data = jsonDecode(response.body);
//
//       if (data['status'] == 'OK') {
//         polylines.clear();
//         for (int i = 0; i < data['routes'].length; i++) {
//           final route = data['routes'][i];
//           final encodedPolyline = route['overview_polyline']['points'];
//           final polylinePoints = _decodePolyline(encodedPolyline);
//
//           polylines.add(Polyline(
//             polylineId: PolylineId('route_$i'),
//             points: polylinePoints,
//             color: Colors.blue.withOpacity((i + 1) / data['routes'].length),
//             width: 5,
//           ));
//         }
//
//         if (polylines.isNotEmpty && mapController != null) {
//           LatLngBounds bounds = _getLatLngBounds(polylines.first.points);
//           mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//         }
//       } else {
//         debugPrint("Error: ${data['status']} - ${data['error_message'] ?? 'No details provided'}");
//       }
//     } catch (e) {
//       debugPrint("Error fetching routes: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Calculate total distance of the route
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
//     return totalDistance / 1000;
//   }
//
//   // Get LatLng bounds for a list of points
//   LatLngBounds _getLatLngBounds(List<LatLng> points) {
//     double? minLat, maxLat, minLng, maxLng;
//
//     for (LatLng point in points) {
//       minLat = minLat == null ? point.latitude : min(minLat, point.latitude);
//       maxLat = maxLat == null ? point.latitude : max(maxLat, point.latitude);
//       minLng = minLng == null ? point.longitude : min(minLng, point.longitude);
//       maxLng = maxLng == null ? point.longitude : max(maxLng, point.longitude);
//     }
//
//     return LatLngBounds(
//       southwest: LatLng(minLat!, minLng!),
//       northeast: LatLng(maxLat!, maxLng!),
//     );
//   }
//
//   // Decode polyline string into LatLng list
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
//   // Reset all fields and state
//   void resetFields() {
//     startController.clear();
//     destinationControllers.clear();
//     points.clear();
//     path.clear();
//     polylines.clear();
//     markers.clear();
//     distance = 0.0;
//     notifyListeners();
//   }
//
//   // Save the current trip
//   void saveTrip() {
//     if (points.isEmpty) {
//       debugPrint("Cannot save trip. Please ensure all fields are filled.");
//       return;
//     }
//
//     final trip = TripModel(
//       id: const Uuid().v4(),
//       name: 'Trip ${trips.length + 1}',
//       startLocation: startController.text,
//       destination: destinationControllers.isNotEmpty ? destinationControllers.last.text : '',
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
//         );
//       }).toList(),
//       timeDurations: timeDurations,
//     );
//
//     trips.add(trip);
//     resetFields();
//     notifyListeners();
//   }
//
//   // Handle map tap to add a new point
//   void onMapTapped(LatLng position) async {
//     isLoading = true;
//     isSavedTrip = false;
//
//     points.add(position);
//     path.add(position);
//
//     if (points.length == 1) {
//       startController.text = "${position.latitude}, ${position.longitude}";
//     } else {
//       final controller = TextEditingController(
//         text: "${position.latitude}, ${position.longitude}",
//       );
//       destinationControllers.add(controller);
//     }
//
//     if (points.length >= 2) {
//       distance = _calculateTotalDistance();
//      // isSave = true;
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
//         snippet: '${position.latitude}, ${position.longitude}',
//       ),
//     ));
//
//     if (points.length >= 2) {
//       await fetchRouteWithWaypoints(path);
//     }
//     isLoading = false;
//     notifyListeners();
//   }
// }