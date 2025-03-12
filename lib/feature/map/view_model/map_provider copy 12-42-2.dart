// import 'dart:convert';
// import 'dart:convert';
// // import 'dart:ffi';
// import 'dart:math';
// import 'package:coyotex/core/services/model/weather_model.dart';
// import 'package:coyotex/core/services/server_calls/trip_apis.dart';
// import 'package:coyotex/core/utills/constant.dart';
// import 'package:coyotex/core/utills/shared_pref.dart';
// import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
// import 'package:coyotex/feature/map/presentation/marker_details_bottom_sheet.dart';
// import 'package:coyotex/feature/map/presentation/start_trip_bootom_sheat.dart';
// import 'package:coyotex/utils/app_dialogue_box.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import '../data/trip_model.dart';
// import 'package:flutter/widgets.dart';

// import 'package:geocoding/geocoding.dart';

// class MapProvider with ChangeNotifier {
//   final TextEditingController startController = TextEditingController();
//   TextEditingController destinationController = TextEditingController();
//   final List<TextEditingController> destinationControllers = [];
//   int destinationCount = 1;
//   List<TripModel> trips = [];
//   bool isTap = true;
//   final Set<Polyline> polylines = {};
//   Set<Marker> mapMarkers = {};
//   List<MarkerData> markers = [];
//   List<LatLng> points = [];
//   List<LatLng> path = [];
//   late TripModel selectedTripModel;
//   bool providerLetsHuntButton = false;
//   String selectedWindDirection = 'North';

//   final String sessionToken = const Uuid().v4();
//   var kGoogleApiKey = "AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s";
//   String markerId = '';
//   List<dynamic> startSuggestions = [];
//   List<dynamic> destinationSuggestions = [];
//   GoogleMapController? mapController;
//   LatLng initialPosition = const LatLng(26.862421770613125, 80.99804357972356);
//   int timeDurations = 0;
//   // int travelTime = 0;
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
//   double speed = 45;

//   late BitmapDescriptor _markerIcon;
//   TripAPIs _tripAPIs = TripAPIs();
//   late WeatherResponse weather = defaultWeatherResponse;
//   final String apiKey = "AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s";
//   int totalTime = 0;
//   String totalTravelTime = "";
//   String totalStopTime = "";
//   getTrips() async {
//     isLoading = true;
//     notifyListeners();
//     var response = await _tripAPIs.getUserTrip();
//     if (response.success) {
//       trips = (response.data["data"] as List).map((item) {
//         return TripModel.fromJson(item);
//       }).toList();
//     }
//     notifyListeners();
//     isLoading = false;
//   }

//   void updateCameraPosition(LatLng newPosition) {
//     if (mapController == null) return;

//     mapController!.animateCamera(
//       CameraUpdate.newLatLngZoom(newPosition, 10),
//     );

//     mapController!.animateCamera(CameraUpdate.scrollBy(24, 80));

//     notifyListeners();
//   }

//   Future<bool> showDurationPicker(BuildContext context,
//       {bool isStop = false}) async {
//     bool? result = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DurationPickerBottomSheet(isStop: isStop),
//     );
//     return result ?? false;
//   }

//   //  Future<bool> showDurationPicker(BuildContext context,
//   //     {bool isStop = false}) async {
//   //   TextEditingController minuteController = TextEditingController();
//   //   // String? selectedWindDirection;
//   //   List<String> windDirections = [
//   //     "North",
//   //     "South",
//   //     "East",
//   //     "West",
//   //     "Northeast",
//   //     "Northwest",
//   //     "Southeast",
//   //     "Southwest"
//   //   ];

//   //   bool isDurationSet = await showDialog<bool>(
//   //         context: context,
//   //         builder: (BuildContext context) {
//   //           return AlertDialog(
//   //             shape: RoundedRectangleBorder(
//   //               borderRadius: BorderRadius.circular(16.0),
//   //             ),
//   //             elevation: 8.0,
//   //             backgroundColor: Colors.white,
//   //             title: const Center(
//   //               child: Text(
//   //                 "Set Duration",
//   //                 style: TextStyle(
//   //                   fontSize: 22,
//   //                   fontWeight: FontWeight.bold,
//   //                   color: Colors.blueGrey,
//   //                 ),
//   //               ),
//   //             ),
//   //             content: Column(
//   //               mainAxisSize: MainAxisSize.min,
//   //               children: [
//   //                 TextField(
//   //                   controller: minuteController,
//   //                   keyboardType: TextInputType.number,
//   //                   decoration: InputDecoration(
//   //                     labelText: "Enter time in minutes",
//   //                     labelStyle: TextStyle(color: Colors.blueGrey[600]),
//   //                     hintText: "e.g., 30",
//   //                     hintStyle: TextStyle(color: Colors.grey[400]),
//   //                     border: OutlineInputBorder(
//   //                       borderRadius: BorderRadius.circular(12.0),
//   //                       borderSide: const BorderSide(color: Colors.blueGrey),
//   //                     ),
//   //                     focusedBorder: OutlineInputBorder(
//   //                       borderRadius: BorderRadius.circular(12.0),
//   //                       borderSide: const BorderSide(
//   //                           color: Colors.blueAccent, width: 2.0),
//   //                     ),
//   //                     filled: true,
//   //                     fillColor: Colors.blueGrey[50],
//   //                   ),
//   //                   style:
//   //                       const TextStyle(color: Colors.blueGrey, fontSize: 16),
//   //                 ),
//   //                 const SizedBox(height: 20),
//   //                 DropdownButtonFormField<String>(
//   //                   decoration: InputDecoration(
//   //                     labelText: "Select Wind Direction",
//   //                     border: OutlineInputBorder(
//   //                       borderRadius: BorderRadius.circular(12.0),
//   //                     ),
//   //                   ),
//   //                   value: selectedWindDirection,
//   //                   items: windDirections.map((String direction) {
//   //                     return DropdownMenuItem<String>(
//   //                       value: direction,
//   //                       child: Text(direction),
//   //                     );
//   //                   }).toList(),
//   //                   onChanged: (String? newValue) {
//   //                     selectedWindDirection = newValue!;
//   //                   },
//   //                 ),
//   //               ],
//   //             ),
//   //             actions: [
//   //               TextButton(
//   //                 onPressed: () {
//   //                   Navigator.of(context).pop(false);
//   //                 },
//   //                 child: const Text(
//   //                   "Cancel",
//   //                   style: TextStyle(
//   //                     color: Colors.redAccent,
//   //                     fontSize: 16,
//   //                     fontWeight: FontWeight.bold,
//   //                   ),
//   //                 ),
//   //               ),
//   //               ElevatedButton(
//   //                 onPressed: () async {
//   //                   if (minuteController.text.isNotEmpty &&
//   //                       selectedWindDirection != null) {
//   //                     int minutes = int.parse(minuteController.text);
//   //                     await setTimeDuration(minutes, isStop: isStop);
//   //                     Navigator.of(context).pop(true);
//   //                   } else {
//   //                     Navigator.of(context).pop(false);
//   //                   }
//   //                 },
//   //                 style: ElevatedButton.styleFrom(
//   //                   backgroundColor: Colors.blueAccent,
//   //                   shape: RoundedRectangleBorder(
//   //                     borderRadius: BorderRadius.circular(12.0),
//   //                   ),
//   //                   padding: const EdgeInsets.symmetric(
//   //                       horizontal: 24, vertical: 12),
//   //                 ),
//   //                 child: const Text(
//   //                   "Set",
//   //                   style: TextStyle(
//   //                     color: Colors.white,
//   //                     fontSize: 16,
//   //                     fontWeight: FontWeight.bold,
//   //                   ),
//   //                 ),
//   //               ),
//   //             ],
//   //           );
//   //         },
//   //       ) ??
//   //       false;

//   //   return isDurationSet;
//   // }

//   Future<void> getWeather(LatLng latAndLng) async {
//     isLoading = true;
//     var response =
//         await _tripAPIs.getWeather(latAndLng.latitude, latAndLng.longitude);
//     weather = WeatherResponse.fromJson(response);
//     isLoading = false;
//   }

//   Future<void> getCurrentLocation() async {
//     isLoading = true;
//     try {
//       // Check if location services are enabled
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw Exception('Location services are disabled.');
//       }

//       // Check and request location permission
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception('Location permissions are denied.');
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw Exception('Location permissions are permanently denied.');
//       }

//       // Get the current position
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       // Update initial position with the retrieved coordinates
//       initialPosition = LatLng(position.latitude, position.longitude);
//       await getWeather(initialPosition);
//       isLoading = false;

//       notifyListeners();
//     } catch (e) {
//       debugPrint("Error getting current location: $e");
//     }
//   }

//   /// Load custom live location icon
//   void loadCustomLiveLocationIcon() async {
//     _markerIcon = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(100, 100)),
//       'assets/images/marker_icon.png',
//     );
//   }

//   String convertMinutesToHours({bool isTotal = true, bool}) {
//     double minutes = isTotal
//         ? (totalTime + ((distance) / speed) * 60)
//         : ((distance) / speed) * 60;

//     int hours = minutes ~/ 60;
//     int remainingMinutes =
//         (minutes % 60).truncate(); // Ensures an integer value

//     String hourText = hours > 0 ? "$hours hr" : "";
//     String minuteText = remainingMinutes > 0 ? "$remainingMinutes min" : "";
//     totalTravelTime =
//         [hourText, minuteText].where((element) => element.isNotEmpty).join(" ");
//     notifyListeners();

//     return [hourText, minuteText]
//         .where((element) => element.isNotEmpty)
//         .join(" ");
//   }

//   void increaseCount() {
//     destinationCount += 1;
//     TextEditingController _textController = TextEditingController();
//     destinationControllers.add(_textController);
//     notifyListeners();
//   }

//   void letsHunt() async {
//     isTripStart = true;
//     isSave = false;
//     isLoading = true;
//     onTapOnMap = false;

//     notifyListeners();

//     try {
//       // Request location permissions
//       final user = Provider.of<UserViewModel>(context, listen: false);
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw Exception('Location services are disabled.');
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception('Location permissions are denied.');
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw Exception('Location permissions are permanently denied.');
//       }

//       // Get the initial location and fetch the route
//       Position initialPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       path.add(LatLng(initialPosition.latitude, initialPosition.longitude));

//       // Fetch the route only once
//       await fetchRouteWithWaypoints(path);
//       // updateCameraPosition(LatLng(initialPosition.latitude, initialPosition.longitude));

//       isLoading = false;
//       notifyListeners();

//       // Start listening to location updates for the user pointer
//       Geolocator.getPositionStream(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 5, // Update only if user moves 5 meters
//         ),
//       ).listen((Position position) {
//         double distanceTravelled = Geolocator.distanceBetween(
//           initialPosition.latitude,
//           initialPosition.longitude,
//           position.latitude,
//           position.longitude,
//         );
//         // print(distanceTravelled);
//         if (user.user.userUnit == "KM") {
//           distance = distance - distanceTravelled / 1000;
//         } else {
//           distance = distance - distanceTravelled / 1609.34;
//         }

//         convertMinutesToHours();

//         if (mapController != null) {
//           mapController!.animateCamera(
//             CameraUpdate.newLatLng(
//                 LatLng(position.latitude, position.longitude)),
//           );
//         }

//         // notifyListeners();
//       });
//     } catch (e) {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   void addStop() async {
//     try {
//       isLoading = true;
//       isHurryUp = false;
//       isKeyDataPoint = false;
//       isTripStart = true;

//       notifyListeners();
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw Exception('Location services are disabled.');
//       }

//       // Check and request location permission
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception('Location permissions are denied.');
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw Exception('Location permissions are permanently denied.');
//       }

//       Position currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       LatLng currentStop =
//           LatLng(currentPosition.latitude, currentPosition.longitude);

//       points.add(currentStop);
//       path.add(currentStop);
//       String locationName = await _getLocationName(
//           LatLng(currentStop.latitude, currentStop.longitude));

//       final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
//       markerId = uniqueId;
//       markers.add(MarkerData(
//         animalSeen: '0',
//         animalKilled: '0',
//         wind_degree: 0,
//         wind_direction: selectedWindDirection,
//         id: uniqueId,
//         position: currentStop,
//         icon: "markerIcon",
//         title: "Stop",
//         snippet: locationName,
//         duration: timeDurations,
//         markerType: "inbetween",
//       ));

//       // Fetch and redraw the updated route
//       await fetchRouteWithWaypoints(path);

//       // Recalculate the total distance
//       distance = calculateTotalDistance();
//       notifyListeners();
//       await showDurationPicker(context).then((value) async {
//         var response = await _tripAPIs.addStop(
//           MarkerData(
//             animalSeen: '0',
//             animalKilled: '0',
//             wind_degree: 0,
//             wind_direction: selectedWindDirection,
//             id: uniqueId,
//             position: currentStop,
//             icon: "markerIcon",
//             title: "Stop",
//             snippet: locationName,
//             duration: timeDurations,
//             markerType: "inbetween",
//           ),
//           selectedTripModel.id,
//         );
//         List<Map<String, dynamic>> dataPoint = [
//           {
//             "latitude": currentStop.latitude,
//             "longitude": currentStop.longitude
//           },
//         ];

//         response = await _tripAPIs.addPoint(
//           selectedTripModel.id,
//           dataPoint,
//         );
//         List<String> waypoint = [locationName, locationName];
//         response = await _tripAPIs.addWayPoints(
//           selectedTripModel.id,
//           waypoint,
//         );
//       });
//       isSave = false;
//     } catch (e) {
//       debugPrint("Error while adding a stop: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   void hurryUp() {
//     isTripStart = false;
//     isSave = false;
//     isHurryUp = false;
//     isKeyDataPoint = true;
//     notifyListeners();
//   }

//   void submit(BuildContext context) {
//     isTripStart = false;
//     isSave = false;
//     isHurryUp = false;
//     isKeyDataPoint = false;

//     resetFields();
//     Navigator.of(context).pop();
//     Navigator.of(context).pop();
//     notifyListeners();
//   }

//   void saveTrip(BuildContext context) async {
//     isLoading = true;
//     notifyListeners();
//     if (points.isEmpty) {
//       debugPrint("Cannot save trip. Please ensure all fields are filled.");
//       return;
//     }
//     String userId = SharedPrefUtil.getValue(userIdPref, "") as String;
//     WeatherMarker _weatherMarker = WeatherMarker(
//         location: Weatherlocation(
//             timezone: weather.timezone,
//             name: weather.name,
//             country: weather.sys.country,
//             latitude: weather.coord.lat,
//             longitude: weather.coord.lon),
//         weather: WeatherData(
//             temperature: weather.main.temp,
//             feelsLike: weather.main.feelsLike,
//             tempMin: weather.main.tempMin,
//             tempMax: weather.main.tempMax,
//             pressure: weather.main.pressure,
//             humidity: weather.main.humidity,
//             visibility: weather.visibility,
//             windSpeed: weather.wind.speed,
//             windDegree: weather.wind.deg,
//             windGust: weather.wind.gust,
//             cloudiness: weather.clouds.all,
//             weatherMain: weather.weather.first.main,
//             weatherDescription: weather.weather.first.description,
//             weatherIcon: weather.weather.first.icon,
//             sunrise: weather.sys.sunrise,
//             sunset: weather.sys.sunset,
//             recordedAt: weather.timezone));

//     List<WeatherMarker> lstWeatherMarker = [];

//     lstWeatherMarker.add(_weatherMarker);
//     final trip = TripModel(
//         id: const Uuid().v4(),
//         animalSeen: 0,
//         animalKilled: 0,
//         name: 'Trip ${trips.length + 1}',
//         startLocation: startController.text,
//         destination: destinationController.text,
//         waypoints: destinationControllers.map((c) => c.text).toList(),
//         totalDistance: distance,
//         createdAt: DateTime.now(),
//         routePoints: List.from(points),
//         markers: markers,
//         images: [],
//         weatherMarkers: lstWeatherMarker,
//         userId: userId);

//     var res = await _tripAPIs.addTrip(trip);
//     if (res.success) {
//       await getTrips();

//       resetFields();
//     } else {
//       AppDialog.showErrorDialog(context, res.message, () {
//         Navigator.of(context).pop();
//       });
//     }
//     isLoading = false;
//     notifyListeners();
//   }

//   late BuildContext context;
//   Future<void> onSuggestionSelected(String placeId, bool isStartField,
//       TextEditingController _controller, BuildContext buildContext) async {
//     isLoading = true;
//     final url =
//         'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey';

//     try {
//       final response = await http.get(Uri.parse(url));
//       final data = jsonDecode(response.body);

//       if (data['status'] == 'OK') {
//         final location = data['result']['geometry']['location'];
//         final latAndLng = LatLng(location['lat'], location['lng']);
//         _controller.text = data['result']['formatted_address'];
//         if (isStartField) {
//           startController.text = data['result']['formatted_address'];

//           TextEditingController _1stController = TextEditingController();
//           destinationControllers.add((_1stController));
//           // pointA = latAndLng;
//           // markerId = 'start';
//         } else {
//           destinationController.text = data['result']['formatted_address'];
//           destinationControllers.last.text =
//               data['result']['formatted_address'];
//           // pointB = latAndLng;
//           // markerId = 'destination';
//         }
//         updateCameraPosition(latAndLng);
//         String locationName = await _getLocationName(latAndLng);

//         points.add(latAndLng);
//         path.add(latAndLng);

//         if (points.length >= 2) {
//           distance = calculateTotalDistance();
//           isSave = true;
//           isHurryUp = false;
//           isKeyDataPoint = false;
//           isTripStart = false;
//         }

//         final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
//         markerId = uniqueId;

//         markers.add(MarkerData(
//           animalSeen: '0',
//           animalKilled: '0',
//           wind_degree: 0,
//           wind_direction: selectedWindDirection,
//           id: uniqueId,
//           position: latAndLng,
//           icon: "assets/images/stop.icon",
//           title: 'Point ${points.length}',
//           snippet: locationName,
//           duration: timeDurations,
//           markerType: "inbetween",
//         ));
//         // markers.add(Marker(
//         //   markerId: MarkerId(uniqueId),
//         //   // // icon: _markerIcon,
//         //   position: latAndLng,
//         //   infoWindow: InfoWindow(
//         //     title: 'Point ${points.length}',
//         //     snippet: '${latAndLng.latitude}, ${latAndLng.longitude}',
//         //   ),
//         // ));

//         if (points.isNotEmpty) {
//           initialPosition = LatLng(points[0].latitude, points[0].longitude);
//         }
//         isSavedTrip = false;
//         providerLetsHuntButton = false;
//         await fetchRouteWithWaypoints(
//           path,
//         );
//         isLoading = false;

//         notifyListeners();
//         await showDurationPicker(context);
//       }
//     } catch (e) {
//       debugPrint("Error fetching place details: $e");
//     }
//   }

//   void onMapTapped(LatLng position, BuildContext buildContext) async {
//     isLoading = true;
//     isSavedTrip = false;
//     onTapOnMap = true;

//     points.add(position);
//     path.add(position);

//     // Fetch location name
//     String locationName = await _getLocationName(position);

//     if (points.length == 1) {
//       startController.text = locationName;
//     } else {
//       final controller = TextEditingController(text: locationName);
//       destinationControllers.add(controller);
//       destinationController = controller;
//     }

//     if (points.length >= 2) {
//       distance = calculateTotalDistance();
//       isSave = true;
//       isHurryUp = false;
//       isKeyDataPoint = false;
//       isTripStart = false;
//     }

//     final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
//     markerId = uniqueId;

//     markers.add(MarkerData(
//       animalSeen: '0',
//       animalKilled: '0',
//       wind_degree: 0,
//       wind_direction: selectedWindDirection,
//       id: uniqueId,
//       position: position,
//       icon: "markerIcon",
//       title: 'Point ${points.length}',
//       snippet: locationName,
//       duration: timeDurations,
//       markerType: "inbetween",
//     ));

//     if (points.length >= 2) {
//       await fetchRouteWithWaypoints(path);
//     }

//     isLoading = false;

//     notifyListeners();
//     Future.delayed(Duration(seconds: 1)).then((value) {
//       showDurationPicker(buildContext);
//     });
//   }

//   // Reset input fields and points
//   void resetFields() {
//     startController.clear();
//     destinationController.clear();
//     destinationControllers.clear();
//     mapMarkers.clear();
//     points.clear();
//     path.clear();
//     markers.clear();
//     isSavedTrip = false;
//     onTapOnMap = false;
//     isTripStart = false;
//     providerLetsHuntButton = false;
//     polylines.clear();
//     markers.clear();
//     onTapOnMap = false;
//     isSave = false;
//     distance = 0.0;
//     totalTime = 0;
//     destinationCount = 1;
//     timeDurations = 0;
//     notifyListeners();
//   }

//   Future<void> setTimeDuration(int duration, String name,
//       {bool isStop = false}) async {
//     timeDurations = duration;
//     totalTime += duration;
//     if (!isStop) {
//       if (markers.isNotEmpty) {
//         markers.last.duration = duration;
//         if (name.isNotEmpty) {
//           markers.last.title = name;
//         }
//         markers.last.wind_direction = selectedWindDirection;
//       }
//     }

//     notifyListeners();
//   }

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

//   Future<String> getPlaceName(LatLng location) async {
//     final url =
//         'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey';

//     final response = await http.get(Uri.parse(url));
//     final data = jsonDecode(response.body);

//     if (data['status'] == 'OK' && data['results'].isNotEmpty) {
//       return data['results'][0]['formatted_address']; // Return first result
//     } else {
//       return "${location.latitude}, ${location.longitude}"; // Fallback to LatLng
//     }
//   }

//   int selectedRouteIndex = 0;
//   List<Map<String, dynamic>> routeDetails = [];

//   Future<void> fetchRouteWithWaypoints(List<LatLng> locations,
//       {bool isRemove = false}) async {
//     if (locations.isEmpty || (locations.length < 2 && !isRemove)) {
//       debugPrint("At least two locations are required.");
//       return;
//     }

//     if (locations.length == 1) {
//       locations.add(locations.first);
//     }

//     isLoading = true;
//     notifyListeners();

//     try {
//       // Convert LatLng to Place Names
//       List<String> placeNames = await Future.wait(locations.map(getPlaceName));

//       String origin = placeNames.first;
//       String destination = placeNames.last;

//       String waypoints = placeNames
//           .sublist(1, placeNames.length - 1)
//           .join('|'); // Middle points as waypoints

//       // Fetch routes using Place Names
//       final url =
//           'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&waypoints=optimize:true|&mode=driving&alternatives=true&key=$apiKey';

//       final response = await http.get(Uri.parse(url));
//       final data = jsonDecode(response.body);

//       if (data['status'] == 'OK') {
//         polylines.clear();

//         // Calculate the shortest route
//         int shortestRouteIndex = 0;
//         double shortestDistance = double.infinity;

//         for (int i = 0; i < data['routes'].length; i++) {
//           final route = data['routes'][i];
//           final encodedPolyline = route['overview_polyline']['points'];
//           final polylinePoints = _decodePolyline(encodedPolyline);
          

//           double distance = calculateTotalDistanceForMap(polylinePoints);
//           if (distance < shortestDistance) {
//             shortestDistance = distance;
//             shortestRouteIndex = i;
//           }
//         }

//         // Assign colors based on the route
//         for (int i = 0; i < data['routes'].length; i++) {
//           final route = data['routes'][i];
//           final encodedPolyline = route['overview_polyline']['points'];
//           final polylinePoints = _decodePolyline(encodedPolyline);

//           if (i == shortestRouteIndex) {
//             // Shortest route: dark blue with border
//             polylines.add(Polyline(
//               polylineId: PolylineId('route_${i}_border'),
//               points: polylinePoints,
//               color: Colors.blue[900]!, // Dark blue border
//               width: 10, // Thicker for clear effect
//             ));
//             polylines.add(Polyline(
//               polylineId: PolylineId('route_${i}_inner'),
//               points: polylinePoints,
//               color: Colors.blue, // Inner blue for consistency
//               width: 6, // Slightly thinner
//             ));
//           } else {
//             // Other routes: light blue with opacity
//             polylines.add(Polyline(
//               polylineId: PolylineId('route_${i}_border'),
//               points: polylinePoints,
//               color: Colors.blue.withOpacity(0.5), // Light blue border
//               width: 10,
//             ));
//             polylines.add(Polyline(
//               polylineId: PolylineId('route_${i}_inner'),
//               points: polylinePoints,
//               color: Colors.white, // White inner
//               width: 5,
//             ));
//           }

//           debugPrint("Route $i: ${route['summary']}"); // Logs route names
//         }

//         if (polylines.isNotEmpty && mapController != null) {
//           LatLngBounds bounds = _getLatLngBounds(polylines.first.points);
//           mapController
//               ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//         }

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

//   double calculateTotalDistanceForMap(List<LatLng> points) {
//     double totalDistance = 0.0;
//     for (int i = 0; i < points.length - 1; i++) {
//       totalDistance += _coordinateDistance(
//         points[i].latitude,
//         points[i].longitude,
//         points[i + 1].latitude,
//         points[i + 1].longitude,
//       );
//     }
//     return totalDistance;
//   }

//   double _coordinateDistance(
//       double lat1, double lon1, double lat2, double lon2) {
//     const p = 0.017453292519943295;
//     final a = 0.5 -
//         cos((lat2 - lat1) * p) / 2 +
//         cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
//     return 12742 * asin(sqrt(a));
//   }

//   void selectRoute(int index) {
//     selectedRouteIndex = index;
//     notifyListeners();
//   }

//   Future<void> getPlaceSuggestions(String input, bool isStartField) async {
//     isStartSuggestions = true;
//     if (input.isEmpty) {
//       if (isStartField) {
//         startSuggestions = [];
//       } else {
//         destinationSuggestions = [];
//       }

//       return;
//     }

//     try {
//       final url =
//           'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$kGoogleApiKey&sessiontoken=$sessionToken';
//       final response = await http.get(Uri.parse(url));
//       final data = jsonDecode(response.body);

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

//   void adjustCameraBounds() {
//     if (points.isNotEmpty && mapController != null) {
//       LatLngBounds bounds = _getLatLngBounds(points);
//       mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//     }
//   }

//   double calculateTotalDistance({bool isRefresh = false}) {
//     final userProvider = Provider.of<UserViewModel>(context, listen: false);
//     double totalDistance = 0.0;

//     for (int i = 0; i < points.length - 1; i++) {
//       totalDistance += Geolocator.distanceBetween(
//         points[i].latitude,
//         points[i].longitude,
//         points[i + 1].latitude,
//         points[i + 1].longitude,
//       );
//     }

//     if (userProvider.user.userUnit == "KM") {
//       totalDistance = totalDistance / 1000; // Convert meters to kilometers
//     } else if (userProvider.user.userUnit == "Miles") {
//       totalDistance = totalDistance / 1609.34; // Convert meters to miles
//     }
//     if (isRefresh) {
//       distance = totalDistance;
//       notifyListeners();
//     }
//     return totalDistance;
//   }

//   LatLngBounds _getLatLngBounds(List<LatLng> points) {
//     double? minLat, maxLat, minLng, maxLng;

//     for (LatLng point in points) {
//       if (minLat == null || point.latitude < minLat) minLat = point.latitude;
//       if (maxLat == null || point.latitude > maxLat) maxLat = point.latitude;
//       if (minLng == null || point.longitude < minLng) minLng = point.longitude;
//       if (maxLng == null || point.longitude > maxLng) maxLng = point.longitude;
//     }

//     return LatLngBounds(
//       southwest: LatLng(minLat!, minLng!),
//       northeast: LatLng(maxLat!, maxLng!),
//     );
//   }

//   List<LatLng> _decodePolyline(String encoded) {
//     final polyline = <LatLng>[];
//     int index = 0, len = encoded.length;
//     int lat = 0, lng = 0;

//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;

//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;

//       polyline.add(LatLng(lat / 1E5, lng / 1E5));
//     }

//     return polyline;
//   }

//   Future<String> _getLocationName(LatLng position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks.first;
//         return "${place.name}, ${place.locality}, ${place.country}";
//       }
//     } catch (e) {
//       print("Error fetching location name: $e");
//     }
//     return "Unknown Location";
//   }

//   void onRemove(LatLng position) async {
//     isLoading = true;
//     notifyListeners();

//     points.remove(position);
//     path.remove(position);

//     markers.removeWhere((marker) => marker.position == position);
//     mapMarkers.removeWhere((marker) => marker.position == position);
//     destinationControllers.removeWhere(
//       (controller) =>
//           controller.text == "${position.latitude}, ${position.longitude}",
//     );

//     if (points.isEmpty) {
//       isSave = false;
//       isHurryUp = false;
//       isKeyDataPoint = false;
//       isTripStart = false;
//       distance = 0.0;
//     } else if (points.length >= 2) {
//       // distance = calculateTotalDistance();
//     }
//     await fetchRouteWithWaypoints(path, isRemove: true);

//     isLoading = false;
//     notifyListeners();
//   }
// }
