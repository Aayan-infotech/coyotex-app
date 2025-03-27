// import 'dart:async';
// import 'dart:convert';
// import 'dart:convert';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:coyotex/core/services/model/notification_model.dart';
// import 'package:coyotex/core/services/model/weather_model.dart';
// import 'package:coyotex/core/services/server_calls/trip_apis.dart';
// import 'package:coyotex/core/utills/constant.dart';
// import 'package:coyotex/core/utills/shared_pref.dart';
// import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
// import 'package:coyotex/feature/map/presentation/marker_details_bottom_sheet.dart';
// import 'package:coyotex/feature/map/presentation/start_trip_bootom_sheat.dart';
// import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
// import 'package:coyotex/utils/app_dialogue_box.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import '../data/trip_model.dart';
// import 'package:flutter/widgets.dart';
// import 'dart:ui' as ui;

// import 'package:geocoding/geocoding.dart';

// class RouteSegment {
//   final List<LatLng> points;
//   final double distance;
//   final int duration;
//   final String summary;

//   RouteSegment({
//     required this.points,
//     required this.distance,
//     required this.duration,
//     required this.summary,
//   });
// }

// List<Map<String, dynamic>> _combineRouteSegments(
//     List<List<RouteSegment>> allSegments) {
//   List<Map<String, dynamic>> combinedRoutes = [];
//   if (allSegments.isEmpty) return combinedRoutes;

//   // Initialize with the first segment's routes
//   for (var segment in allSegments.first) {
//     combinedRoutes.add({
//       'polyPoints': List<LatLng>.from(segment.points),
//       'distance': segment.distance,
//       'duration': segment.duration,
//       'summary': segment.summary,
//     });
//   }

//   // Iterate through remaining segments and combine
//   for (int i = 1; i < allSegments.length; i++) {
//     List<Map<String, dynamic>> temp = [];
//     for (var route in combinedRoutes) {
//       for (var segment in allSegments[i]) {
//         List<LatLng> combinedPoints = List.from(route['polyPoints'])
//           ..addAll(segment.points);
//         temp.add({
//           'polyPoints': combinedPoints,
//           'distance': route['distance'] + segment.distance,
//           'duration': route['duration'] + segment.duration,
//           'summary': '${route['summary']} → ${segment.summary}',
//         });
//       }
//     }
//     combinedRoutes = temp;
//   }

//   return combinedRoutes;
// }

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
//   List<Map<String, dynamic>> routeDetails = [];
//   final String sessionToken = const Uuid().v4();
//   //"AIzaSyDg2wdDb3SFR1V_3DO2mNVvc01Dh6vR5Mc";
//   String markerId = '';
//   List<dynamic> startSuggestions = [];
//   List<dynamic> destinationSuggestions = [];
//   GoogleMapController? mapController;
//   LatLng initialPosition = const LatLng(26.862421770613125, 80.99804357972356);
//   int timeDurations = 0;

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
//   bool isRestart = false;
//   TripAPIs _tripAPIs = TripAPIs();
//   late WeatherResponse weather = defaultWeatherResponse;

//   int totalTime = 0;
//   String totalTravelTime = "";
//   String totalStopTime = "";
//   List<MarkerData> liveTripMarker = [];
//   Marker currentLocationMarker = const Marker(
//     markerId: MarkerId("currentLocation"),
//   );

//   MarkerData? selectedOldMarker;
//   bool isStartavigation = false;
//   List<MarkerData> lstTripMarkerData = [];
//   getTrips() async {
//     isLoading = true;
//     notifyListeners();

//     var response = await _tripAPIs.getUserTrip();

//     if (response.success) {
//       trips = (response.data["data"] as List)
//           .map((item) => TripModel.fromJson(item))
//           .toList();

//       for (var trip in trips) {
//         int minLength = trip.markers.length < trip.weatherMarkers.length
//             ? trip.markers.length
//             : trip.weatherMarkers.length;

//         for (int i = 0; i < minLength; i++) {
//           trip.markers[i].temperature =
//               trip.weatherMarkers[i].weather.temperature;
//         }
//       }

//       print(trips);
//     }

//     notifyListeners();
//     isLoading = false;
//   }

//   void onMapCreated(GoogleMapController controller) {
//     mapController = controller;

//     if (routeList.isNotEmpty) {
//       final points = routeList[selectedRouteIndex]['polyPoints'];
//       LatLngBounds bounds = _getLatLngBounds(points);
//       controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 10));
//     } else if (points.isNotEmpty) {
//       adjustCameraBounds();
//     } else {
//       // Set zoom level to 0 (or minimum possible zoom)
//       controller.animateCamera(CameraUpdate.newLatLngZoom(
//           LatLng(initialPosition.latitude, initialPosition.longitude), 10));
//     }

//     setMarkersWithOnTap(context);
//     notifyListeners();
//   }

//   void adjustCameraBounds() {
//     if (points.isNotEmpty && mapController != null) {
//       LatLngBounds bounds = _getLatLngBounds(points);
//       mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
//     }
//   }

//   void updateCameraPosition(LatLng newPosition) {
//     if (mapController == null) return;

//     try {
//       final CameraPosition newCameraPosition = CameraPosition(
//         target: newPosition,
//         zoom: 10,
//         tilt: 0, // Optional: Adjust for 3D effect if needed
//       );

//       mapController!.animateCamera(
//         CameraUpdate.newCameraPosition(newCameraPosition),
//       );

//       // // Wait for the first animation to complete before applying another
//       // Future.delayed(const Duration(milliseconds: 500), () {
//       //   mapController!.animateCamera(CameraUpdate.scrollBy(24, 20));
//       // });

//       notifyListeners();
//     } catch (error) {
//       print("Error in updateCameraPosition: $error");
//     }
//   }

//   void updateMapMarkers(List<MarkerData> mar) {
//     mapMarkers.clear();
//     for (var item in mar) {
//       mapMarkers.add(Marker(
//         markerId: MarkerId(item.id),
//         position: item.position,
//         infoWindow: InfoWindow(title: item.title, snippet: item.snippet),
//       ));
//     }
//     setMarkersWithOnTap(context);
//     notifyListeners();
//   }

//   Future<bool> showDurationPicker(BuildContext context,
//       {bool isStop = false, Marker? marker}) async {
//     bool? result = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       isDismissible: false,
//       enableDrag: false,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DurationPickerBottomSheet(
//         isStop: isStop,
//         mapMarker: marker,
//       ),
//     );
//     return result ?? false;
//   }

//   void setMarkersWithOnTap(
//     BuildContext context,
//   ) {
//     mapMarkers = mapMarkers.map((item) {
//       return item.copyWith(
//         onTapParam: () {
//           onTapOnMap = true;
//           showDurationPicker(context, marker: item);
//         },
//       );
//     }).toSet();
//     notifyListeners();
//   }

//   Future<void> getWeather(LatLng latAndLng) async {
//     isLoading = true;
//     var response =
//         await _tripAPIs.getWeather(latAndLng.latitude, latAndLng.longitude);
//     weather = WeatherResponse.fromJson(response);
//     isLoading = false;
//   }

//   Future<Position> getCurrentLocation({bool isCurrentLocation = false}) async {
//     // isLoading = true;
//     try {
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

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       initialPosition = LatLng(position.latitude, position.longitude);
//       if (!isCurrentLocation) await getWeather(initialPosition);
//       // isLoading = false;
//       notifyListeners();

//       return position;
//     } catch (e) {
//       debugPrint("Error getting current location: $e");

//       return Position(
//           longitude: 23,
//           latitude: 23,
//           timestamp: DateTime.now(),
//           accuracy: 3,
//           altitude: 1,
//           altitudeAccuracy: 2,
//           heading: 2,
//           headingAccuracy: 3,
//           speed: speed,
//           speedAccuracy: 3);
//     }
//   }

//   LatLng currentCameraTarget = const LatLng(28.00, 28.00);
//   double currentZoom = 12;

//   void onCameraMove(CameraPosition position) {
//     currentCameraTarget = position.target;
//     currentZoom = position.zoom;
//     notifyListeners();
//   }

//   // String convertMinutesToHours(double distance, {bool isTotal = true, bool}) {
//   //   double minutes = isTotal
//   //       ? (totalTime + ((distance / 1000) / speed) * 60)
//   //       : ((distance) / speed) * 60;

//   //   int hours = minutes ~/ 60;
//   //   int remainingMinutes =
//   //       (minutes % 60).truncate(); // Ensures an integer value

//   //   String hourText = hours > 0 ? "$hours hr" : "";
//   //   String minuteText = remainingMinutes > 0 ? "$remainingMinutes min" : "";
//   //   totalTravelTime =
//   //       [hourText, minuteText].where((element) => element.isNotEmpty).join(" ");
//   //   notifyListeners();

//   //   return [hourText, minuteText]
//   //       .where((element) => element.isNotEmpty)
//   //       .join(" ");
//   // }
//   String convertMinutesToHours(double distance, {bool isTotal = true}) {
//     double minutes = isTotal
//         ? (totalTime + ((distance / 1000) / speed) * 60)
//         : ((distance) / speed) * 60;

//     int hours = minutes ~/ 60;
//     int remainingMinutes =
//         (minutes % 60).truncate(); // Ensures an integer value

//     String hourText = hours > 0 ? "$hours hr" : "";
//     String minuteText = remainingMinutes > 0 ? "$remainingMinutes min" : "";

//     // Assign "4 min" if both hourText and minuteText are empty
//     if (hourText.isEmpty && minuteText.isEmpty) {
//       minuteText = "4 min";
//     }

//     totalTravelTime =
//         [hourText, minuteText].where((element) => element.isNotEmpty).join(" ");
//     notifyListeners();

//     return totalTravelTime;
//   }

//   void increaseCount() {
//     destinationCount += 1;
//     TextEditingController _textController = TextEditingController();
//     destinationControllers.add(_textController);
//     notifyListeners();
//   }

//   bool isNotificationSend = true;

//   int currentMarkerIndex = 0;
//   bool hasSentArrivalNotification = false;
//   bool isAtStop = false;
//   Timer? stayTimer;
//   static const double arrivalThreshold = 50; // meters
//   StreamSubscription<Position>? positionStream;
//   String formattedDistance = '';
//   List<LatLng> routePolylinePoints = [];
//   List<double> cumulativeDistances = [];
//   int lastClosestPointIndex = 0;
//   double totalRouteDistance = 0.0;

//   List<double> _computeCumulativeDistances(List<LatLng> points) {
//     List<double> distances = [0.0];
//     for (int i = 1; i < points.length; i++) {
//       double dist = _coordinateDistance(
//         points[i - 1].latitude,
//         points[i - 1].longitude,
//         points[i].latitude,
//         points[i].longitude,
//       );
//       distances.add(distances.last + dist);
//     }
//     return distances;
//   }

//   double _coordinateDistance(
//       double lat1, double lon1, double lat2, double lon2) {
//     const p = 0.017453292519943295;
//     final a = 0.5 -
//         cos((lat2 - lat1) * p) / 2 +
//         cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
//     return 12742 * asin(sqrt(a)) * 1000; // Return distance in meters
//   }

//   int selectedRouteIndex = 0;
//   List<Map<String, dynamic>> routeList = [];

//   int shortestRouteIndex = 0;
//   bool showAllRoutes = true;
//   // void selectRoute(int index) {
//   //   selectedRouteIndex = index;
//   //   distance = routeList[index]['distance'];
//   //   _updatePolylines();
//   //   notifyListeners();
//   // }

//   void selectRoute(int index) {
//     selectedRouteIndex = index;
//     showAllRoutes = false;
//     routePolylinePoints = routeList[index]['polyPoints'];
//     cumulativeDistances = _computeCumulativeDistances(routePolylinePoints);
//     totalRouteDistance = cumulativeDistances.last;

//     distance = double.parse(
//         (routeList[index]["distance"]).toString()); //totalRouteDistance;
//     formattedDistance = formatDistance(distance, context);
//     convertMinutesToHours(distance);

//     _updatePolylines();
//     notifyListeners();
//   }

//   String formatDistance(double meters, BuildContext context) {
//     final userProvider = Provider.of<UserViewModel>(context, listen: false);

//     if (userProvider.user.userUnit == "Miles") {
//       if (meters < 1609.34) {
//         // Less than 1 mile
//         return '${(meters / 1609.34).toStringAsFixed(1)} mi';
//       }
//       final miles = meters / 1609.34;
//       return '${miles.toStringAsFixed(2)} mi';
//     } else {
//       // Kilometers
//       if (meters < 1000) {
//         return '${meters.toStringAsFixed(2)} m';
//       }
//       final km = meters / 1000;
//       return '${km.toStringAsFixed(2)} km';
//     }
//   }

//   int _findClosestPointIndex(LatLng currentPosition) {
//     if (routePolylinePoints.isEmpty) return 0;

//     int closestIndex = 0;
//     double minDistance = double.infinity;

//     // Search the entire route if no previous index is known
//     for (int i = 0; i < routePolylinePoints.length; i++) {
//       final point = routePolylinePoints[i];
//       final distance = Geolocator.distanceBetween(
//         currentPosition.latitude,
//         currentPosition.longitude,
//         point.latitude,
//         point.longitude,
//       );

//       if (distance < minDistance) {
//         minDistance = distance;
//         closestIndex = i;
//       }
//     }

//     lastClosestPointIndex = closestIndex;
//     return closestIndex;
//   }

//   // int _findClosestPointIndex(LatLng currentPosition) {
//   //   // Start searching from last known position for efficiency
//   //   int startIndex = max(0, lastClosestPointIndex - 10);
//   //   double minDistance = double.infinity;
//   //   int closestIndex = startIndex;

//   //   for (int i = startIndex; i < routePolylinePoints.length; i++) {
//   //     final point = routePolylinePoints[i];
//   //     final distance = Geolocator.distanceBetween(
//   //       currentPosition.latitude,
//   //       currentPosition.longitude,
//   //       point.latitude,
//   //       point.longitude,
//   //     );

//   //     if (distance < minDistance) {
//   //       minDistance = distance;
//   //       closestIndex = i;
//   //     }
//   //     // Early exit if moving away from route
//   //     if (i > startIndex + 20 && distance > minDistance * 2) break;
//   //   }

//   //   lastClosestPointIndex = closestIndex;
//   //   return closestIndex;
//   // }

//   Stream<LatLng>? locationStream;

//   Future<WeatherResponse> getCurrentWeather(LatLng latAndLng) async {
//     // isLoading = true;
//     // notifyListeners();
//     var response =
//         await _tripAPIs.getWeather(latAndLng.latitude, latAndLng.longitude);
//     // isLoading = false;
//     // notifyListeners();
//     return WeatherResponse.fromJson(response);
//   }

//   int remainingStopTime = 0;
//   Timer? countdownTimer;

//   bool isRedText = false;
//   bool hasSent2MinNotification = false;
//   void letsHunt() async {
//     isTripStart = true;
//     isSave = false;
//     isLoading = true;
//     onTapOnMap = false;
//     currentMarkerIndex = 0;
//     hasSentArrivalNotification = false;
//     isAtStop = false;
//     stayTimer?.cancel();
//     stayTimer = null;

//     notifyListeners();
//     late LatLng startTripLatLang;

//     try {
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

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       LatLng initialLatLng = LatLng(position.latitude, position.longitude);
//       startTripLatLang = initialLatLng;
//       //updateCameraPosition(initialLatLng);
//       // path.add(initialLatLng);

//       if (!_isWithinRadius(initialLatLng, path, 1000)) {
//         path.add(initialLatLng);
//       }

//       await fetchRouteWithWaypoints(path, isPathShow: true);

//       isLoading = false;
//       // formattedDistance = formatDistance(distance, context);
//       // notifyListeners();

//       positionStream = Geolocator.getPositionStream(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 6,
//         ),
//       ).listen((Position position) async {
//         LatLng currentLatLng = LatLng(position.latitude, position.longitude);

//         // Update current location marker
//         currentLocationMarker = Marker(
//           markerId: const MarkerId("currentLocation"),
//           position: currentLatLng,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//           infoWindow: const InfoWindow(title: "Current Location"),
//         );

//         // Clear old markers and add the updated current location
//         mapMarkers.removeWhere((m) => m.markerId.value == "currentLocation");
//         mapMarkers.add(currentLocationMarker);
//         initialPosition = currentLatLng;
//         notifyListeners();

//         // Update camera and notify
//         // mapController?.animateCamera(CameraUpdate.newLatLng(currentLatLng));

//         // notifyListeners();

//         // Check if there are markers to process
//         if (!isAtStop &&
//             currentMarkerIndex < selectedTripModel.markers.length) {
//           final currentMarker = selectedTripModel.markers[currentMarkerIndex];
//           double distanceToMarker = Geolocator.distanceBetween(
//             currentLatLng.latitude,
//             currentLatLng.longitude,
//             currentMarker.position.latitude,
//             currentMarker.position.longitude,
//           );

//           // Check if arrived at the current marker
//           if (distanceToMarker <= arrivalThreshold) {
//             isAtStop = true;
//             hasSentArrivalNotification = false;

//             // Send arrival notification
//             final userProvider =
//                 Provider.of<UserViewModel>(context, listen: false);
//             userProvider.sendNotifications(
//               "Trip Update",
//               "Arrived at stop ${currentMarkerIndex + 1}",
//               NotificationType.tripUpdate,
//               selectedTripModel.id,
//             );
//             int stayDuration = currentMarker.duration;
//             remainingStopTime = stayDuration * 60; // Convert minutes to seconds
//             hasSent2MinNotification = false;
//             isRedText = false;

//             // Cancel existing timers
//             countdownTimer?.cancel();
//             stayTimer?.cancel();

//             // if (stayDuration > 2) {
//             //   stayTimer = Timer(
//             //     Duration(minutes: stayDuration - 2),
//             //     () {
//             //       userProvider.sendNotifications(
//             //         "Trip Update",
//             //         "2 minutes left at stop ${currentMarkerIndex + 1}",
//             //         NotificationType.tripUpdate,
//             //         selectedTripModel.id,
//             //       );
//             //       remainingStopTime = 120; // 2 minutes in seconds
//             //       countdownTimer?.cancel(); // Cancel existing timer
//             //       countdownTimer =
//             //           Timer.periodic(Duration(seconds: 1), (timer) {
//             //         if (remainingStopTime > 0) {
//             //           remainingStopTime--;
//             //           notifyListeners();
//             //         } else {
//             //           timer.cancel();
//             //         }
//             //       });
//             //     },
//             //   );
//             // }
//             countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//               if (remainingStopTime > 0) {
//                 remainingStopTime--;

//                 // Check if 2 minutes left and send notification once
//                 if (remainingStopTime <= 120 && !hasSent2MinNotification) {
//                   userProvider.sendNotifications(
//                     "Trip Update",
//                     "2 minutes left at stop ${currentMarkerIndex + 1}",
//                     NotificationType.tripUpdate,
//                     selectedTripModel.id,
//                   );
//                   hasSent2MinNotification = true;
//                   isRedText = true;
//                 }

//                 notifyListeners();
//               } else {
//                 // Time's up, move to next marker
//                 timer.cancel();
//                 currentMarkerIndex++;
//                 isAtStop = false;
//                 isRedText = false;
//                 remainingStopTime = 0;
//                 notifyListeners();
//               }
//             });

//             // Schedule moving to next marker after full duration
//             Timer(
//               Duration(minutes: stayDuration),
//               () {
//                 stayTimer?.cancel();
//                 currentMarkerIndex++;
//                 isAtStop = false;
//                 countdownTimer?.cancel();
//                 remainingStopTime = 0;
//                 currentMarkerIndex++;
//                 notifyListeners();
//               },
//             );
//             WeatherResponse currentWeather =
//                 await getCurrentWeather(currentMarker.position);
//             WeatherMarker _weatherMarker = WeatherMarker(
//                 location: Weatherlocation(
//                   timezone: currentWeather.timezone,
//                   name: currentWeather.name,
//                   country: currentWeather.sys.country,
//                   latitude: currentMarker.position.latitude,
//                   longitude: currentMarker.position.longitude,
//                 ),
//                 weather: WeatherData(
//                     temperature: currentWeather.main.temp,
//                     feelsLike: currentWeather.main.feelsLike,
//                     tempMin: currentWeather.main.tempMin,
//                     tempMax: currentWeather.main.tempMax,
//                     pressure: currentWeather.main.pressure,
//                     humidity: currentWeather.main.humidity,
//                     visibility: currentWeather.visibility,
//                     windSpeed: currentWeather.wind.speed,
//                     windDegree: currentWeather.wind.deg,
//                     windGust: currentWeather.wind.gust,
//                     cloudiness: currentWeather.clouds.all,
//                     weatherMain: currentWeather.weather.first.main,
//                     weatherDescription:
//                         currentWeather.weather.first.description,
//                     weatherIcon: currentWeather.weather.first.icon,
//                     sunrise: currentWeather.sys.sunrise,
//                     sunset: currentWeather.sys.sunset,
//                     recordedAt: currentWeather.timezone));
//             await _tripAPIs.addWeatherMarker(
//                 selectedTripModel.id, _weatherMarker);
//           } else {
//             // Calculate ETA if possible
//             double speed = position.speed ?? 0;
//             if (speed > 1) {
//               double etaSeconds = distanceToMarker / speed;
//               if (etaSeconds <= 5 * 60 && !hasSentArrivalNotification) {
//                 final userProvider =
//                     Provider.of<UserViewModel>(context, listen: false);
//                 userProvider.sendNotifications(
//                   "Trip Update",
//                   "5 minutes until arrival at stop ${currentMarkerIndex + 1}",
//                   NotificationType.tripUpdate,
//                   selectedTripModel.id,
//                 );
//                 hasSentArrivalNotification = true;
//               }
//             }
//           }
//         }
//         // final closestIndex = _findClosestPointIndex(currentLatLng);
//         double? travelledDistance = await getDistance(
//             origin: startTripLatLang, destination: currentLatLng);
//         final remainingDistance = cumulativeDistances.last - travelledDistance!;

//         distance = remainingDistance > 0 ? remainingDistance : 0;
//         formattedDistance = formatDistance(remainingDistance, context);
//         convertMinutesToHours(distance);
//         // }

//         // updateCameraPosition(initialLatLng);
//       });
//     } catch (e) {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<double> getDistanceBetween(
//       double lat1, double lon1, double lat2, double lon2) async {
//     String apiKey = "AIzaSyDg2wdDb3SFR1V_3DO2mNVvc01Dh6vR5Mc";
//     String url =
//         "https://maps.googleapis.com/maps/api/directions/json?origin=$lat1,$lon1&destination=$lat2,$lon2&key=$apiKey";

//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['routes'].isNotEmpty) {
//         double distanceMeters =
//             data['routes'][0]['legs'][0]['distance']['value'].toDouble();
//         return distanceMeters / 1000; // Convert meters to km
//       }
//     }
//     return 0.0;
//   }

//   /// Helper function to check if a LatLng is within a given radius (meters) of any point in a list
//   bool _isWithinRadius(
//       LatLng newPoint, List<LatLng> existingPoints, double radius) {
//     for (LatLng point in existingPoints) {
//       double distance = Geolocator.distanceBetween(
//         newPoint.latitude,
//         newPoint.longitude,
//         point.latitude,
//         point.longitude,
//       );
//       if (distance <= radius) {
//         return true; // Found a point within the radius, so return true
//       }
//     }
//     return false; // No points found within the radius
//   }

//   void addStop(LatLng positionasync {
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

//   void saveTrip(BuildContext context) async {
//     final tripProvidr = Provider.of<TripViewModel>(context, listen: false);
//     isLoading = true;
//     notifyListeners();
//     if (points.isEmpty) {
//       debugPrint("Cannot save trip. Please ensure all fields are filled.");
//       return;
//     }
//     String userId = SharedPrefUtil.getValue(userIdPref, "") as String;

//     final trip = TripModel(
//         tripStatus: 'created',
//         id: const Uuid().v4(),
//         animalSeen: 0,
//         animalKilled: 0,
//         name: 'Trip ${trips.length + 1}',
//         startLocation: startController.text.isNotEmpty
//             ? startController.text
//             : "Location 1",
//         destination: destinationController.text.isEmpty
//             ? "Location"
//             : destinationController.text,
//         waypoints: destinationControllers.map((c) => c.text).toList(),
//         totalDistance: distance,
//         createdAt: DateTime.now(),
//         routePoints: List.from(points),
//         markers: markers,
//         images: [],
//         weatherMarkers: [], //lstWeatherMarker,
//         userId: userId);

//     var res = await _tripAPIs.addTrip(trip);
//     if (res.success) {
//       await getTrips();
//       await tripProvidr.getAllMarker();

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

//   bool isProcessingTap = false;
//   void onMapTapped(LatLng position, BuildContext buildContext) async {
//     isLoading = true;
//     isSavedTrip = false;
//     onTapOnMap = true;
//     if (isProcessingTap) return; // Prevent multiple taps
//     isProcessingTap = true;

//     notifyListeners();

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
//       // distance = calculateTotalDistance();
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

//     Future.delayed(Duration(seconds: 0)).then((value) {
//       showDurationPicker(buildContext);
//     });
//     setMarkersWithOnTap(context);
//     isProcessingTap = false;
//     notifyListeners();
//   }

//   Future<double?> getDistance({
//     required LatLng origin,
//     required LatLng destination,
//   }) async {
//     const String apiKey = "AIzaSyDg2wdDb3SFR1V_3DO2mNVvc01Dh6vR5Mc";

//     final String url =
//         "https://maps.googleapis.com/maps/api/distancematrix/json?"
//         "origins=${origin.latitude},${origin.longitude}"
//         "&destinations=${destination.latitude},${destination.longitude}"
//         "&key=$apiKey";

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data["status"] == "OK") {
//           var elements = data["rows"][0]["elements"][0];
//           if (elements["status"] == "OK") {
//             int distanceInMeters =
//                 elements["distance"]["value"]; // Distance in meters
//             return distanceInMeters.toDouble();
//           }
//         }
//       }
//       return null;
//     } catch (e) {
//       print("Error fetching distance: $e");
//       return null;
//     }
//   }

//   void resetFields() {
//     final tripProvider = Provider.of<TripViewModel>(context, listen: false);

//     isProcessingTap = false;

//     isStartavigation = false;
//     startController.clear();

//     if (countdownTimer != null) {
//       countdownTimer!.cancel();
//     }

//     tripProvider.lstMarker.clear();
//     tripProvider.lstMarker = List.from(tripProvider.lstAllMarker);

//     remainingStopTime = 0;
//     destinationController.clear();
//     destinationControllers.clear();
//     markers.clear();
//     mapMarkers.clear();
//     points = [];
//     path = [];
//     isSavedTrip = false;
//     onTapOnMap = false;
//     isTripStart = false;
//     providerLetsHuntButton = false;
//     polylines.clear();
//     isSave = false;
//     distance = 0.0;
//     totalTime = 0;
//     destinationCount = 1;
//     timeDurations = 0;

//     if (positionStream != null) {
//       positionStream!.cancel();
//     }

//     // Force UI update
//     updateMapMarkers(tripProvider.lstMarker);
//   }

//   Future<void> setTimeDuration(int duration, String name,
//       {bool isStop = false}) async {
//     // final provider = Provider.of<TripViewModel>(context, listen: false);

//     timeDurations = duration;
//     totalTime += duration;
//     if (!isStop) {
//       if (markers.isNotEmpty) {
//         markers.last.duration = duration;
//         if (name.isNotEmpty) {
//           markers.last.title = name;
//         }
//         markers.last.wind_direction = selectedWindDirection;
//         final provider = Provider.of<TripViewModel>(context, listen: false);
//         provider.lstMarker.add(markers.last);
//         updateMapMarkers(provider.lstMarker);
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
//         'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$kGoogleApiKey';

//     final response = await http.get(Uri.parse(url));
//     final data = jsonDecode(response.body);

//     if (data['status'] == 'OK' && data['results'].isNotEmpty) {
//       return data['results'][0]['formatted_address']; // Return first result
//     } else {
//       return "${location.latitude}, ${location.longitude}"; // Fallback to LatLng
//     }
//   }

//   void toggleRouteDisplay() async {
//     // isLoading = true;
//     // notifyListeners();
//     showAllRoutes = !showAllRoutes;
//     _updatePolylines();
//     //s isLoading = false;
//     notifyListeners();
//   }

//   bool isPolylines = false;
//   // void _updatePolylines() {
//   //   polylines.clear();

//   //   if (routeList.isEmpty) return;

//   //   // Draw selected route
//   //   final selectedRoute = routeList[selectedRouteIndex];
//   //   polylines.add(Polyline(
//   //     polylineId: PolylineId('selected_route'),
//   //     points: selectedRoute['polyPoints'],
//   //     color: Colors.blue,
//   //     width: 5,
//   //   ));

//   //   // Optionally draw other routes
//   //   if (showAllRoutes) {
//   //     for (int i = 0; i < routeList.length; i++) {
//   //       if (i == selectedRouteIndex) continue;
//   //       polylines.add(Polyline(
//   //         polylineId: PolylineId('route_$i'),
//   //         points: routeList[i]['polyPoints'],
//   //         color: Colors.grey,
//   //         width: 3,
//   //       ));
//   //     }
//   //   }

//   //   notifyListeners();
//   // }

//   Future<void> _updatePolylines() async {
//     polylines.clear();

//     if (showAllRoutes) {
//       // Draw all routes with appropriate styling
//       for (int i = 0; i < routeList.length; i++) {
//         await _addRoutePolyline(routeList[i]['polyPoints'],
//             i == selectedRouteIndex, i == shortestRouteIndex);
//       }
//     } else {
//       // Draw only selected route
//       await _addRoutePolyline(
//           routeList[selectedRouteIndex]['polyPoints'], true, false);
//     }

//     // Update camera position
//     if (polylines.isNotEmpty && mapController != null) {
//       final points = routeList[selectedRouteIndex]['polyPoints'];
//       LatLngBounds bounds = _getLatLngBounds(points);
//       mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
//     }
//   }

//   Future<void> _addRoutePolyline(
//       List<LatLng> points, bool isSelected, bool isShortest) async {
//     if (isSelected) {
//       polylines.add(Polyline(
//         polylineId: const PolylineId('route_selected_border'),
//         points: points,
//         color: Colors.blue[900]!,
//         width: 10,
//       ));
//       polylines.add(Polyline(
//         polylineId: PolylineId('route_selected_inner'),
//         points: points,
//         color: Colors.blue,
//         width: 6,
//       ));
//     } else if (isShortest) {
//       polylines.add(Polyline(
//         polylineId: const PolylineId('route_shortest_border'),
//         points: points,
//         color: Colors.blue.withOpacity(0.3),
//         width: 10,
//       ));
//       polylines.add(Polyline(
//         polylineId: const PolylineId('route_shortest_inner'),
//         points: points,
//         color: Colors.white,
//         width: 6,
//       ));
//     } else {
//       polylines.add(Polyline(
//         polylineId: PolylineId('route_${points.hashCode}_border'),
//         points: points,
//         color: Colors.blue.withOpacity(0.3),
//         width: 10,
//       ));
//       polylines.add(Polyline(
//         polylineId: PolylineId('route_${points.hashCode}_inner'),
//         points: points,
//         color: Colors.white.withOpacity(0.7),
//         width: 5,
//       ));
//     }
//   }

//   List<Map<String, String>> distanceOfSegments = [];

//   List<Map<String, dynamic>> segmentDistances = [];
//   double totalDirectDistance = 0.0;

//   Future<Map<String, dynamic>?> calculateSegmentDistances(
//       List<LatLng> locations) async {
//     if (locations.length < 2) return null;

//     try {
//       List<Map<String, dynamic>> segments = [];
//       double total = 0.0;

//       // Calculate distances between consecutive markers
//       for (int i = 0; i < locations.length - 1; i++) {
//         final origin = locations[i];
//         final destination = locations[i + 1];

//         final double? distance = await getDistance(
//           origin: origin,
//           destination: destination,
//         );

//         if (distance != null) {
//           final startName = await getPlaceName(origin);
//           final endName = await getPlaceName(destination);

//           segments.add({
//             'from': startName,
//             'to': endName,
//             'distance': distance,
//             'coordinates': {'start': origin, 'end': destination}
//           });
//           total += distance;
//         }
//       }

//       // Calculate direct distance from first to last marker
//       final double? directDistance = await getDistance(
//         origin: locations.first,
//         destination: locations.last,
//       );

//       return {
//         'segments': segments,
//         'totalPathDistance': total,
//         'totalDirectDistance': directDistance ?? 0.0
//       };
//     } catch (e) {
//       debugPrint("Error calculating distances: $e");
//       return null;
//     }
//   }

//   // Future<void> fetchRouteWithWaypoints(
//   //   List<LatLng> locations, {
//   //   bool isRemove = false,
//   //   bool isPathShow = false,
//   // }) async {
//   //   // if (locations.isEmpty || (locations.length < 2 && !isRemove)) {
//   //   //   debugPrint("At least two locations are required.");
//   //   //   return;
//   //   // }
//   //   if (isRemove) {
//   //     locations.add(locations.first);
//   //   }

//   //   isLoading = true;
//   //   // notifyListeners();
//   //   routeList = [];
//   //   distanceOfSegments = []; // Reset distances

//   //   try {
//   //     List<String> placeNames = await Future.wait(locations.map(getPlaceName));
//   //     List<List<RouteSegment>> allSegments = [];

//   //     for (int i = 0; i < locations.length - 1; i++) {
//   //       String origin = placeNames[i];
//   //       String destination = placeNames[i + 1];
//   //       final url = 'https://maps.googleapis.com/maps/api/directions/json?'
//   //           'origin=$origin&destination=$destination&mode=driving&'
//   //           'alternatives=true&key=$kGoogleApiKey';

//   //       final response = await http.get(Uri.parse(url));
//   //       final data = jsonDecode(response.body);

//   //       if (data['status'] == 'OK') {
//   //         List<RouteSegment> segmentRoutes = [];

//   //         for (var route in data['routes']) {
//   //           final encodedPolyline = route['overview_polyline']['points'];

//   //           final polylinePoints = _decodePolyline(encodedPolyline);
//   //           // routePolylinePoints =
//   //           //     polylinePoints; //routeList[index]['polyPoints'];
//   //           // cumulativeDistances =
//   //           //     _computeCumulativeDistances(routePolylinePoints);
//   //           double distance = route['legs'][0]['distance']['value'].toDouble();
//   //           int duration = route['legs'][0]['duration']['value'];

//   //           segmentRoutes.add(RouteSegment(
//   //             points: polylinePoints,
//   //             distance: distance,
//   //             duration: duration,
//   //             summary: route['summary'],
//   //           ));

//   //           //  Store the distance in the list
//   //           distanceOfSegments.add({
//   //             "$origin to $destination": "${(distance).toStringAsFixed(2)}"
//   //           });
//   //         }

//   //         allSegments.add(segmentRoutes);
//   //       } else {
//   //         debugPrint("Error in segment $i: ${data['status']}");
//   //         return;
//   //       }
//   //     }

//   //     routeList = _combineRouteSegments(allSegments);
//   //     if (routeList.length > 3) {
//   //       routeList = routeList.sublist(0, 3);
//   //     }

//   //     if (routeList.isNotEmpty) {
//   //       selectedRouteIndex = 0;
//   //       double shortestDistance = routeList.first['distance'];
//   //       for (int i = 1; i < routeList.length; i++) {
//   //         if (routeList[i]['distance'] < shortestDistance) {
//   //           shortestDistance = routeList[i]['distance'];
//   //           // distance = shortestDistance;
//   //           selectedRouteIndex = i;
//   //         } else {
//   //           //distance = shortestDistance;
//   //         }
//   //       }
//   //       if (locations.length >= 2) {
//   //         distance = await calculateTotalDistanceForMap(locations);
//   //       }

//   //       _updatePolylines();
//   //       // if (polylines.isNotEmpty && mapController != null) {
//   //       //   LatLngBounds bounds = _getLatLngBounds(polylines.first.points);
//   //       //   mapController
//   //       //       ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//   //       // }
//   //     }

//   //     if (isPathShow) showRoutesBottomSheet(context);

//   //     debugPrint("Distance of Segments: $distanceOfSegments");
//   //   } catch (e) {
//   //     debugPrint("Error fetching routes: $e");
//   //   } finally {
//   //     isLoading = false;
//   //     notifyListeners();
//   //   }
//   // }
//   // logic to get only one route
//   Future<void> fetchRouteWithWaypoints(
//     List<LatLng> locations, {
//     bool isRemove = false,
//     bool isPathShow = false,
//   }) async {
//     if (locations.length < 2) {
//       debugPrint("At least two locations are required.");
//       return;
//     }

//     isLoading = true;
//     notifyListeners();
//     routeList = [];

//     try {
//       // Build origin and destination
//       final origin = "${locations.first.latitude},${locations.first.longitude}";
//       final destination =
//           "${locations.last.latitude},${locations.last.longitude}";

//       // Build waypoints parameter if intermediate points exist
//       String waypoints = "";
//       if (locations.length > 2) {
//         waypoints = "&waypoints=" +
//             locations
//                 .sublist(1, locations.length - 1)
//                 .map((latLng) => "${latLng.latitude},${latLng.longitude}")
//                 .join("|");
//       }

//       // Single API call with all waypoints
//       final url = 'https://maps.googleapis.com/maps/api/directions/json?'
//           'origin=$origin&destination=$destination$waypoints&mode=driving&'
//           'alternatives=true&key=$kGoogleApiKey';

//       final response = await http.get(Uri.parse(url));
//       final data = jsonDecode(response.body);

//       if (data['status'] == 'OK') {
//         routeList.clear();

//         // Process each complete route
//         for (var route in data['routes']) {
//           final encodedPolyline = route['overview_polyline']['points'];
//           final polylinePoints = _decodePolyline(encodedPolyline);

//           // Calculate total distance and duration
//           double totalDistance = 0;
//           int? totalDuration = 0;
//           for (var leg in route['legs']) {
//             totalDistance = (leg['distance']['value'] as num).toDouble();
//             distance = totalDistance;
//             // totalDuration += (leg['duration']['value'] as num).toDouble();
//           }

//           routeList.add({
//             'polyPoints': polylinePoints,
//             'distance': totalDistance,
//             'duration': totalDuration,
//             'summary': route['summary'],
//           });
//         }

//         // Find shortest route
//         if (routeList.isNotEmpty) {
//           double shortestDistance = routeList.first['distance'];
//           selectedRouteIndex = 0;
//           for (int i = 0; i < routeList.length; i++) {
//             if (routeList[i]['distance'] < shortestDistance) {
//               shortestDistance = routeList[i]['distance'];
//               selectedRouteIndex = i;
//             }
//           }
//           // distance = shortestDistance;
//           if (locations.length >= 2) {
//             // distance = await calculateTotalDistanceForMap(locations);
//             // notifyListeners();
//           }

//           _updatePolylines();
//         }
//         if (locations.length >= 2) {
//           distance = await calculateTotalDistanceForMap(locations);
//           selectRoute(0);

//           // notifyListeners();
//         }

//         _updatePolylines();
//       }
//     } catch (e) {
//       debugPrint("Error fetching routes: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Add this in your provider class

//   void showRoutesBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               padding: const EdgeInsets.all(16),
//               height: MediaQuery.of(context).size.height * 0.45,
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Available Routes',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue[800],
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(showAllRoutes
//                             ? Icons.visibility_off
//                             : Icons.visibility),
//                         onPressed: () {
//                           toggleRouteDisplay();

//                           // setState(() {
//                           //   //showAllRoutes = !showAllRoutes;
//                           // });
//                         },
//                         tooltip: showAllRoutes
//                             ? 'Hide other routes'
//                             : 'Show all routes',
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: routeList.length,
//                       itemBuilder: (context, index) {
//                         final route = routeList[index];
//                         final isSelected = index == selectedRouteIndex;
//                         final isShortest = index == shortestRouteIndex;

//                         return GestureDetector(
//                           onTap: () {
//                             selectRoute(index);
//                             // setState(() {
//                             //   selectedRouteIndex = index;
//                             //   distance = route['distance'];
//                             // });
//                             Navigator.pop(context);
//                           },
//                           child: Card(
//                             color: isSelected
//                                 ? Colors.blue[50]
//                                 : isShortest
//                                     ? Colors.green[50]
//                                     : Colors.white,
//                             elevation: 2,
//                             shape: RoundedRectangleBorder(
//                               side: BorderSide(
//                                 color: isSelected
//                                     ? Colors.blue
//                                     : isShortest
//                                         ? Colors.green
//                                         : Colors.grey[300]!,
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: ListTile(
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 8,
//                                 horizontal: 16,
//                               ),
//                               leading: isShortest
//                                   ? const Icon(Icons.star, color: Colors.green)
//                                   : null,
//                               title: Text(
//                                 route['summary'] ?? 'Route ${index + 1}',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: isSelected
//                                       ? Colors.blue[900]
//                                       : isShortest
//                                           ? Colors.green[900]
//                                           : Colors.black,
//                                 ),
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const SizedBox(height: 4),
//                                   _buildInfoRow(
//                                     Icons.directions_car,
//                                     formatDistance(
//                                         double.parse(
//                                             (route['distance']).toString()),
//                                         context),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   _buildInfoRow(
//                                     Icons.access_time,
//                                     _formatDuration(route['duration']),
//                                   )
//                                 ],
//                               ),
//                               trailing: isSelected
//                                   ? const Icon(Icons.check_circle,
//                                       color: Colors.blue)
//                                   : null,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: Colors.grey),
//         const SizedBox(width: 6),
//         Text(text, style: TextStyle(color: Colors.grey[600])),
//       ],
//     );
//   }

//   // String formatDistance(double meters, BuildContext context) {
//   //   final userProvider = Provider.of<UserViewModel>(context, listen: false);

//   //   if (userProvider.user.userUnit == "Miles") {
//   //     double miles = meters / 1609.34; // Convert meters to miles
//   //     return miles > 0.1
//   //         ? '${miles.toStringAsFixed(1)} mi'
//   //         : '${(miles * 5280).toStringAsFixed(0)} ft';
//   //   } else {
//   //     double km = meters / 1000;

//   //     return km > 1 ? '${km.toStringAsFixed(1)} km' : '$meters m';
//   //   }
//   // }

//   String _formatDuration(int seconds) {
//     final hours = seconds ~/ 3600;
//     final minutes = (seconds % 3600) ~/ 60;

//     return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
//   }

//   // double calculateTotalDistanceForMap(List<LatLng> points) {
//   //   double totalDistance = 0.0;
//   //   for (int i = 0; i < points.length - 1; i++) {
//   //     totalDistance += _coordinateDistance(
//   //       points[i].latitude,
//   //       points[i].longitude,
//   //       points[i + 1].latitude,
//   //       points[i + 1].longitude,
//   //     );
//   //   }
//   //   return totalDistance;
//   // }
//   Future<double> calculateTotalDistanceForMap(List<LatLng> points) async {
//     try {
//       if (points.length < 2) return 0.0;

//       String origin = "${points.first.latitude},${points.first.longitude}";
//       String destination = "${points.last.latitude},${points.last.longitude}";

//       // Add intermediate waypoints (if any)
//       String waypoints = "";
//       if (points.length > 2) {
//         waypoints = "&waypoints=" +
//             points
//                 .sublist(1, points.length - 1) // Exclude first and last points
//                 .map((point) => "${point.latitude},${point.longitude}")
//                 .join("|");
//       }

//       // Construct the API URL
//       String url =
//           "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination$waypoints&key=$kGoogleApiKey";

//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data['status'] == "OK" && data['routes'].isNotEmpty) {
//           int distanceMeters = data['routes'][0]['legs']
//               .fold(0, (sum, leg) => sum + leg['distance']['value']);
//           return double.parse(
//               distanceMeters.toString()); // Convert meters to km
//         } else {
//           print(
//               "Google API Error: ${data['status']} - ${data['error_message'] ?? 'No details'}");
//         }
//       } else {
//         print("HTTP Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error calculating distance: $e");
//     }

//     return 0.0;
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

//   // void adjustCameraBounds() {
//   //   if (points.isNotEmpty && mapController != null) {
//   //     LatLngBounds bounds = _getLatLngBounds(points);
//   //     mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//   //   }
//   // }

//   double calculateTotalDistance({bool isRefresh = false}) {
//     final userProvider = Provider.of<UserViewModel>(context, listen: false);
//     double totalDistance = 0.0;

//     // for (int i = 0; i < points.length - 1; i++) {
//     //   totalDistance += _coordinateDistance(
//     //     points[i].latitude,
//     //     points[i].longitude,
//     //     points[i + 1].latitude,
//     //     points[i + 1].longitude,
//     //   );
//     // }

//     if (userProvider.user.userUnit == "KM") {
//       totalDistance = totalDistance / 1000; // Convert meters to kilometers
//     } else if (userProvider.user.userUnit == "Miles") {
//       totalDistance = totalDistance / 1609.34; // Convert meters to miles
//     }
//     if (isRefresh) {
//       //  distance = totalDistance;
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
//     final tripProvider = Provider.of<TripViewModel>(context, listen: false);

//     isLoading = true;
//     notifyListeners();

//     points.remove(position);
//     path.remove(position);

//     markers.removeWhere((marker) => marker.position == position);
//     mapMarkers.removeWhere((marker) => marker.position == position);
//     tripProvider.lstMarker.removeWhere((marker) => marker.position == position);
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
