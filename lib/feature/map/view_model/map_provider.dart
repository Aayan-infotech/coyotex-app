import 'dart:async';
import 'dart:convert';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:coyotex/core/services/model/notification_model.dart';
import 'package:coyotex/core/services/model/weather_model.dart';
import 'package:coyotex/core/services/server_calls/trip_apis.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/map/presentation/marker_details_bottom_sheet.dart';
import 'package:coyotex/feature/map/presentation/start_trip_bootom_sheat.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../data/trip_model.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

import 'package:geocoding/geocoding.dart';

class RouteSegment {
  final List<LatLng> points;
  final double distance;
  final int duration;
  final String summary;

  RouteSegment({
    required this.points,
    required this.distance,
    required this.duration,
    required this.summary,
  });
}

List<Map<String, dynamic>> _combineRouteSegments(
    List<List<RouteSegment>> allSegments) {
  List<Map<String, dynamic>> combinedRoutes = [];
  if (allSegments.isEmpty) return combinedRoutes;

  // Initialize with the first segment's routes
  for (var segment in allSegments.first) {
    combinedRoutes.add({
      'polyPoints': List<LatLng>.from(segment.points),
      'distance': segment.distance,
      'duration': segment.duration,
      'summary': segment.summary,
    });
  }

  // Iterate through remaining segments and combine
  for (int i = 1; i < allSegments.length; i++) {
    List<Map<String, dynamic>> temp = [];
    for (var route in combinedRoutes) {
      for (var segment in allSegments[i]) {
        List<LatLng> combinedPoints = List.from(route['polyPoints'])
          ..addAll(segment.points);
        temp.add({
          'polyPoints': combinedPoints,
          'distance': route['distance'] + segment.distance,
          'duration': route['duration'] + segment.duration,
          'summary': '${route['summary']} → ${segment.summary}',
        });
      }
    }
    combinedRoutes = temp;
  }

  return combinedRoutes;
}

class MapProvider with ChangeNotifier {
  final TextEditingController startController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  final List<TextEditingController> destinationControllers = [];
  int destinationCount = 1;
  List<TripModel> trips = [];
  bool isTap = true;
  final Set<Polyline> polylines = {};
  Set<Marker> mapMarkers = {};
  List<MarkerData> markers = [];
  List<LatLng> points = [];
  List<LatLng> path = [];
  late TripModel selectedTripModel;
  bool providerLetsHuntButton = false;
  String selectedWindDirection = 'North';
  List<Map<String, dynamic>> routeDetails = [];
  final String sessionToken = const Uuid().v4();
  var kGoogleApiKey = "AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s";
  String markerId = '';
  List<dynamic> startSuggestions = [];
  List<dynamic> destinationSuggestions = [];
  GoogleMapController? mapController;
  LatLng initialPosition = const LatLng(26.862421770613125, 80.99804357972356);
  int timeDurations = 0;
  // int travelTime = 0;
  LatLng? pointA;
  LatLng? pointB;
  bool isSave = false;
  bool onTapOnMap = false;
  bool isLoading = false;
  double distance = 0.0;
  bool isTripStart = false;
  bool isHurryUp = false;
  bool isSavedTrip = false;
  bool isKeyDataPoint = false;
  bool isStartSuggestions = false;
  double speed = 45;
  bool isRestart = false;
  TripAPIs _tripAPIs = TripAPIs();
  late WeatherResponse weather = defaultWeatherResponse;
  final String apiKey = "AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s";
  int totalTime = 0;
  String totalTravelTime = "";
  String totalStopTime = "";
  Marker currentLocationMarker = const Marker(
    markerId: MarkerId("currentLocation"),
  );
  MarkerData? selectedOldMarker;
  getTrips() async {
    isLoading = true;
    notifyListeners();
    var response = await _tripAPIs.getUserTrip();
    if (response.success) {
      trips = (response.data["data"] as List).map((item) {
        return TripModel.fromJson(item);
      }).toList();
      print(trips);
    }
    notifyListeners();
    isLoading = false;
  }

  void updateCameraPosition(LatLng newPosition) {
    if (mapController == null) return;

    final CameraPosition newCameraPosition = CameraPosition(
      bearing: 90, // 90 degree rotation (east direction)
      target: newPosition,
      zoom: 10,
      tilt: 0, // Optional: Set to 30-45 if you want 3D tilt
    );
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );

    mapController!.animateCamera(CameraUpdate.scrollBy(24, 80));

    notifyListeners();
  }

  void updateMapMarkers(List<MarkerData> markers) {
    mapMarkers.clear();
    for (var item in markers) {
      mapMarkers.add(Marker(
        markerId: MarkerId(item.id),
        position: item.position,
        infoWindow: InfoWindow(title: item.title, snippet: item.snippet),
      ));
    }
    notifyListeners();
  }

  Future<bool> showDurationPicker(BuildContext context,
      {bool isStop = false, MarkerData? markerData}) async {
    bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DurationPickerBottomSheet(isStop: isStop),
    );
    return result ?? false;
  }

  void setMarkersWithOnTap(BuildContext context) {
    final provider = Provider.of<TripViewModel>(context, listen: false);

    mapMarkers = mapMarkers.map((marker) {
    

      return marker.copyWith(
        onTapParam: () {
          showDurationPicker(context);
        },
      );
    }).toSet();
    notifyListeners();
  }

  Future<void> getWeather(LatLng latAndLng) async {
    isLoading = true;
    var response =
        await _tripAPIs.getWeather(latAndLng.latitude, latAndLng.longitude);
    weather = WeatherResponse.fromJson(response);
    isLoading = false;
  }

  Future<Position> getCurrentLocation() async {
    isLoading = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      initialPosition = LatLng(position.latitude, position.longitude);
      await getWeather(initialPosition);
      isLoading = false;
      notifyListeners();

      return position;
    } catch (e) {
      return Position(
          longitude: 23,
          latitude: 23,
          timestamp: DateTime.now(),
          accuracy: 3,
          altitude: 1,
          altitudeAccuracy: 2,
          heading: 2,
          headingAccuracy: 3,
          speed: speed,
          speedAccuracy: 3);
      debugPrint("Error getting current location: $e");
    }
  }

  LatLng currentCameraTarget = LatLng(28.00, 28.00);
  double currentZoom = 12;

  void onCameraMove(CameraPosition position) {
    currentCameraTarget = position.target;
    currentZoom = position.zoom;
    notifyListeners();
  }

  String convertMinutesToHours(double distance, {bool isTotal = true, bool}) {
    double minutes = isTotal
        ? (totalTime + ((distance / 1000) / speed) * 60)
        : ((distance) / speed) * 60;

    int hours = minutes ~/ 60;
    int remainingMinutes =
        (minutes % 60).truncate(); // Ensures an integer value

    String hourText = hours > 0 ? "$hours hr" : "";
    String minuteText = remainingMinutes > 0 ? "$remainingMinutes min" : "";
    totalTravelTime =
        [hourText, minuteText].where((element) => element.isNotEmpty).join(" ");
    notifyListeners();

    return [hourText, minuteText]
        .where((element) => element.isNotEmpty)
        .join(" ");
  }

  void increaseCount() {
    destinationCount += 1;
    TextEditingController _textController = TextEditingController();
    destinationControllers.add(_textController);
    notifyListeners();
  }

  bool isNotificationSend = true;

  int currentMarkerIndex = 0;
  bool hasSentArrivalNotification = false;
  bool isAtStop = false;
  Timer? stayTimer;
  static const double arrivalThreshold = 50; // meters
  StreamSubscription<Position>? positionStream;
  String formattedDistance = '';
  List<LatLng> routePolylinePoints = [];
  List<double> cumulativeDistances = [];
  int lastClosestPointIndex = 0;
  double totalRouteDistance = 0.0;
  List<double> _computeCumulativeDistances(List<LatLng> points) {
    List<double> distances = [0.0];
    for (int i = 1; i < points.length; i++) {
      double dist = _coordinateDistance(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
      distances.add(distances.last + dist);
    }
    return distances;
  }

  double _coordinateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // Return distance in meters
  }

  int selectedRouteIndex = 0;
  List<Map<String, dynamic>> routeList = [];

  int shortestRouteIndex = 0;
  bool showAllRoutes = true;

  void selectRoute(int index) {
    selectedRouteIndex = index;
    showAllRoutes = false;
    routePolylinePoints = routeList[index]['polyPoints'];
    cumulativeDistances = _computeCumulativeDistances(routePolylinePoints);
    totalRouteDistance = cumulativeDistances.last;
    distance = totalRouteDistance;
    _updatePolylines();
    convertMinutesToHours(distance);
    notifyListeners();
  }

  String formatDistance(double meters, BuildContext context) {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);

    if (userProvider.user.userUnit == "Miles") {
      if (meters < 1609.34) {
        // Less than 1 mile
        return '${(meters / 1609.34).toStringAsFixed(1)} mi';
      }
      final miles = meters / 1609.34;
      return '${miles.toStringAsFixed(2)} mi';
    } else {
      // Kilometers
      if (meters < 1000) {
        return '${meters.toStringAsFixed(2)} m';
      }
      final km = meters / 1000;
      return '${km.toStringAsFixed(2)} km';
    }
  }

  int _findClosestPointIndex(LatLng currentPosition) {
    // Start searching from last known position for efficiency
    int startIndex = max(0, lastClosestPointIndex - 10);
    double minDistance = double.infinity;
    int closestIndex = startIndex;

    for (int i = startIndex; i < routePolylinePoints.length; i++) {
      final point = routePolylinePoints[i];
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        point.latitude,
        point.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
      // Early exit if moving away from route
      if (i > startIndex + 20 && distance > minDistance * 2) break;
    }

    lastClosestPointIndex = closestIndex;
    return closestIndex;
  }

  Stream<LatLng>? locationStream;

  double _calculate5MinuteDistance(double? speed) {
    final metersPerMinute = (speed ?? 1.0) * 60; // Convert m/s to m/min
    return metersPerMinute * 5;
  }

  Future<void> initLocationStream() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return; // Handle permission denial
    }

    locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).map((position) => LatLng(position.latitude, position.longitude));
  }

  Future<WeatherResponse> getCurrentWeather(LatLng latAndLng) async {
    // isLoading = true;
    // notifyListeners();
    var response =
        await _tripAPIs.getWeather(latAndLng.latitude, latAndLng.longitude);
    // isLoading = false;
    // notifyListeners();
    return WeatherResponse.fromJson(response);
  }

  void letsHunt() async {
    isTripStart = true;
    isSave = false;
    isLoading = true;
    onTapOnMap = false;
    currentMarkerIndex = 0;
    hasSentArrivalNotification = false;
    isAtStop = false;
    stayTimer?.cancel();
    stayTimer = null;

    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng initialLatLng =
          LatLng(initialPosition.latitude, initialPosition.longitude);

      if (!_isWithinRadius(initialLatLng, path, 1000)) {
        path.add(initialLatLng);
      }

      await fetchRouteWithWaypoints(path, isPathShow: true);

      isLoading = false;
      notifyListeners();
      formattedDistance = formatDistance(distance, context);

      positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((Position position) async {
        LatLng currentLatLng = LatLng(position.latitude, position.longitude);

        // if (!_isWithinRadius(currentLatLng, path, 1000)) {
        //   path.add(currentLatLng);
        // }

        // Check if there are markers to process
        if (!isAtStop &&
            currentMarkerIndex < selectedTripModel.markers.length) {
          final currentMarker = selectedTripModel.markers[currentMarkerIndex];
          double distanceToMarker = Geolocator.distanceBetween(
            currentLatLng.latitude,
            currentLatLng.longitude,
            currentMarker.position.latitude,
            currentMarker.position.longitude,
          );

          // Check if arrived at the current marker
          if (distanceToMarker <= arrivalThreshold) {
            isAtStop = true;
            hasSentArrivalNotification = false;

            // Send arrival notification
            final userProvider =
                Provider.of<UserViewModel>(context, listen: false);
            userProvider.sendNotifications(
              "Trip Update",
              "Arrived at stop ${currentMarkerIndex + 1}",
              NotificationType.tripUpdate,
              selectedTripModel.id,
            );

            // Schedule 2-minute remaining notification
            int stayDuration = currentMarker.duration;
            if (stayDuration > 2) {
              stayTimer = Timer(
                Duration(minutes: stayDuration - 2),
                () {
                  userProvider.sendNotifications(
                    "Trip Update",
                    "2 minutes left at stop ${currentMarkerIndex + 1}",
                    NotificationType.tripUpdate,
                    selectedTripModel.id,
                  );
                },
              );
            }

            // Schedule moving to next marker after full duration
            Timer(
              Duration(minutes: stayDuration),
              () {
                stayTimer?.cancel();
                currentMarkerIndex++;
                isAtStop = false;
                notifyListeners();
              },
            );
            WeatherResponse currentWeather =
                await getCurrentWeather(currentMarker.position);
            WeatherMarker _weatherMarker = WeatherMarker(
                location: Weatherlocation(
                  timezone: currentWeather.timezone,
                  name: currentWeather.name,
                  country: currentWeather.sys.country,
                  latitude: currentMarker.position.latitude,
                  longitude: currentMarker.position.longitude,
                ),
                weather: WeatherData(
                    temperature: currentWeather.main.temp,
                    feelsLike: currentWeather.main.feelsLike,
                    tempMin: currentWeather.main.tempMin,
                    tempMax: currentWeather.main.tempMax,
                    pressure: currentWeather.main.pressure,
                    humidity: currentWeather.main.humidity,
                    visibility: currentWeather.visibility,
                    windSpeed: currentWeather.wind.speed,
                    windDegree: currentWeather.wind.deg,
                    windGust: currentWeather.wind.gust,
                    cloudiness: currentWeather.clouds.all,
                    weatherMain: currentWeather.weather.first.main,
                    weatherDescription:
                        currentWeather.weather.first.description,
                    weatherIcon: currentWeather.weather.first.icon,
                    sunrise: currentWeather.sys.sunrise,
                    sunset: currentWeather.sys.sunset,
                    recordedAt: currentWeather.timezone));
            await _tripAPIs.addWeatherMarker(
                selectedTripModel.id, _weatherMarker);
          } else {
            // Calculate ETA if possible
            double speed = position.speed ?? 0;
            if (speed > 1) {
              double etaSeconds = distanceToMarker / speed;
              if (etaSeconds <= 5 * 60 && !hasSentArrivalNotification) {
                final userProvider =
                    Provider.of<UserViewModel>(context, listen: false);
                userProvider.sendNotifications(
                  "Trip Update",
                  "5 minutes until arrival at stop ${currentMarkerIndex + 1}",
                  NotificationType.tripUpdate,
                  selectedTripModel.id,
                );
                hasSentArrivalNotification = true;
              }
            }
          }
        }
        final closestIndex = _findClosestPointIndex(currentLatLng);
        final remainingDistance =
            cumulativeDistances.last - cumulativeDistances[closestIndex];

        // Update distance and ETA
        distance = remainingDistance;
        formattedDistance = formatDistance(remainingDistance, context);
        convertMinutesToHours(remainingDistance);
        if (mapController != null) {
          mapController!.animateCamera(CameraUpdate.newLatLng(currentLatLng));
        }

        // Marker arrival logic
        // _handleMarkerArrival(currentLatLng, position.speed);

        notifyListeners();
        // Existing distance calculation and map update logic
        // double distanceTravelled = Geolocator.distanceBetween(
        //   initialPosition.latitude,
        //   initialPosition.longitude,
        //   position.latitude,
        //   position.longitude,
        // );
        // distance -= distanceTravelled;

        // if (mapController != null) {
        //   mapController!.animateCamera(
        //     CameraUpdate.newLatLng(currentLatLng),
        //   );
        // }
        // formattedDistance = formatDistance(distance, context);
        // convertMinutesToHours();

        // notifyListeners();
      });
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Helper function to check if a LatLng is within a given radius (meters) of any point in a list
  bool _isWithinRadius(
      LatLng newPoint, List<LatLng> existingPoints, double radius) {
    for (LatLng point in existingPoints) {
      double distance = Geolocator.distanceBetween(
        newPoint.latitude,
        newPoint.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance <= radius) {
        return true; // Found a point within the radius, so return true
      }
    }
    return false; // No points found within the radius
  }

  void addStop() async {
    try {
      isLoading = true;
      isHurryUp = false;
      isKeyDataPoint = false;
      isTripStart = true;

      notifyListeners();
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentStop =
          LatLng(currentPosition.latitude, currentPosition.longitude);

      points.add(currentStop);
      path.add(currentStop);
      String locationName = await _getLocationName(
          LatLng(currentStop.latitude, currentStop.longitude));

      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      markerId = uniqueId;
      markers.add(MarkerData(
        animalSeen: '0',
        animalKilled: '0',
        wind_degree: 0,
        wind_direction: selectedWindDirection,
        id: uniqueId,
        position: currentStop,
        icon: "markerIcon",
        title: "Stop",
        snippet: locationName,
        duration: timeDurations,
        markerType: "inbetween",
      ));

      // Fetch and redraw the updated route
      await fetchRouteWithWaypoints(path);

      // Recalculate the total distance
      distance = calculateTotalDistance();
      notifyListeners();
      await showDurationPicker(context).then((value) async {
        var response = await _tripAPIs.addStop(
          MarkerData(
            animalSeen: '0',
            animalKilled: '0',
            wind_degree: 0,
            wind_direction: selectedWindDirection,
            id: uniqueId,
            position: currentStop,
            icon: "markerIcon",
            title: "Stop",
            snippet: locationName,
            duration: timeDurations,
            markerType: "inbetween",
          ),
          selectedTripModel.id,
        );
        List<Map<String, dynamic>> dataPoint = [
          {
            "latitude": currentStop.latitude,
            "longitude": currentStop.longitude
          },
        ];

        response = await _tripAPIs.addPoint(
          selectedTripModel.id,
          dataPoint,
        );
        List<String> waypoint = [locationName, locationName];
        response = await _tripAPIs.addWayPoints(
          selectedTripModel.id,
          waypoint,
        );
      });
      isSave = false;
    } catch (e) {
      debugPrint("Error while adding a stop: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void hurryUp() {
    isTripStart = false;
    isSave = false;
    isHurryUp = false;
    isKeyDataPoint = true;
    notifyListeners();
  }

  void submit(BuildContext context) {
    isTripStart = false;
    isSave = false;
    isHurryUp = false;
    isKeyDataPoint = false;

    resetFields();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    notifyListeners();
  }

  void saveTrip(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    if (points.isEmpty) {
      debugPrint("Cannot save trip. Please ensure all fields are filled.");
      return;
    }
    String userId = SharedPrefUtil.getValue(userIdPref, "") as String;
    // WeatherMarker _weatherMarker = WeatherMarker(
    //     location: Weatherlocation(
    //         timezone: weather.timezone,
    //         name: weather.name,
    //         country: weather.sys.country,
    //         latitude: weather.coord.lat,
    //         longitude: weather.coord.lon),
    //     weather: WeatherData(
    //         temperature: weather.main.temp,
    //         feelsLike: weather.main.feelsLike,
    //         tempMin: weather.main.tempMin,
    //         tempMax: weather.main.tempMax,
    //         pressure: weather.main.pressure,
    //         humidity: weather.main.humidity,
    //         visibility: weather.visibility,
    //         windSpeed: weather.wind.speed,
    //         windDegree: weather.wind.deg,
    //         windGust: weather.wind.gust,
    //         cloudiness: weather.clouds.all,
    //         weatherMain: weather.weather.first.main,
    //         weatherDescription: weather.weather.first.description,
    //         weatherIcon: weather.weather.first.icon,
    //         sunrise: weather.sys.sunrise,
    //         sunset: weather.sys.sunset,
    //         recordedAt: weather.timezone));

    // List<WeatherMarker> lstWeatherMarker = [];

    // lstWeatherMarker.add(_weatherMarker);
    final trip = TripModel(
        tripStatus: 'created',
        id: const Uuid().v4(),
        animalSeen: 0,
        animalKilled: 0,
        name: 'Trip ${trips.length + 1}',
        startLocation: startController.text.isNotEmpty
            ? startController.text
            : "Location 1",
        destination: destinationController.text.isEmpty
            ? "Location"
            : destinationController.text,
        waypoints: destinationControllers.map((c) => c.text).toList(),
        totalDistance: distance,
        createdAt: DateTime.now(),
        routePoints: List.from(points),
        markers: markers,
        images: [],
        weatherMarkers: [], //lstWeatherMarker,
        userId: userId);

    var res = await _tripAPIs.addTrip(trip);
    if (res.success) {
      await getTrips();

      resetFields();
    } else {
      AppDialog.showErrorDialog(context, res.message, () {
        Navigator.of(context).pop();
      });
    }
    isLoading = false;
    notifyListeners();
  }

  late BuildContext context;
  Future<void> onSuggestionSelected(String placeId, bool isStartField,
      TextEditingController _controller, BuildContext buildContext) async {
    isLoading = true;
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        final latAndLng = LatLng(location['lat'], location['lng']);
        _controller.text = data['result']['formatted_address'];
        if (isStartField) {
          startController.text = data['result']['formatted_address'];

          TextEditingController _1stController = TextEditingController();
          destinationControllers.add((_1stController));
          // pointA = latAndLng;
          // markerId = 'start';
        } else {
          destinationController.text = data['result']['formatted_address'];
          destinationControllers.last.text =
              data['result']['formatted_address'];
          // pointB = latAndLng;
          // markerId = 'destination';
        }
        updateCameraPosition(latAndLng);
        String locationName = await _getLocationName(latAndLng);

        points.add(latAndLng);
        path.add(latAndLng);

        if (points.length >= 2) {
          distance = calculateTotalDistance();
          isSave = true;
          isHurryUp = false;
          isKeyDataPoint = false;
          isTripStart = false;
        }

        final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
        markerId = uniqueId;

        markers.add(MarkerData(
          animalSeen: '0',
          animalKilled: '0',
          wind_degree: 0,
          wind_direction: selectedWindDirection,
          id: uniqueId,
          position: latAndLng,
          icon: "assets/images/stop.icon",
          title: 'Point ${points.length}',
          snippet: locationName,
          duration: timeDurations,
          markerType: "inbetween",
        ));

        if (points.isNotEmpty) {
          initialPosition = LatLng(points[0].latitude, points[0].longitude);
        }
        isSavedTrip = false;
        providerLetsHuntButton = false;
        await fetchRouteWithWaypoints(
          path,
        );
        isLoading = false;

        notifyListeners();
        await showDurationPicker(context);
      }
    } catch (e) {
      debugPrint("Error fetching place details: $e");
    }
  }

  void onMapTapped(LatLng position, BuildContext buildContext) async {
    isLoading = true;
    isSavedTrip = false;
    onTapOnMap = true;

    points.add(position);
    path.add(position);

    // Fetch location name
    String locationName = await _getLocationName(position);

    if (points.length == 1) {
      startController.text = locationName;
    } else {
      final controller = TextEditingController(text: locationName);
      destinationControllers.add(controller);
      destinationController = controller;
    }

    if (points.length >= 2) {
      // distance = calculateTotalDistance();
      isSave = true;
      isHurryUp = false;
      isKeyDataPoint = false;
      isTripStart = false;
    }

    final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    markerId = uniqueId;

    markers.add(MarkerData(
      animalSeen: '0',
      animalKilled: '0',
      wind_degree: 0,
      wind_direction: selectedWindDirection,
      id: uniqueId,
      position: position,
      icon: "markerIcon",
      title: 'Point ${points.length}',
      snippet: locationName,
      duration: timeDurations,
      markerType: "inbetween",
    ));

    if (points.length >= 2) {
      await fetchRouteWithWaypoints(path);
    }

    isLoading = false;

    notifyListeners();
    Future.delayed(Duration(seconds: 1)).then((value) {
      showDurationPicker(buildContext);
    });
  }

  // Reset input fields and points
  void resetFields() {
    startController.clear();
    destinationController.clear();
    destinationControllers.clear();
    mapMarkers.clear();
    markers.clear();
    points.clear();
    path.clear();
    isSavedTrip = false;
    onTapOnMap = false;
    isTripStart = false;
    providerLetsHuntButton = false;
    polylines.clear();
    onTapOnMap = false;
    isSave = false;
    distance = 0.0;
    totalTime = 0;
    destinationCount = 1;
    timeDurations = 0;
    if (positionStream != null) {
      positionStream!.cancel();
    }
    notifyListeners();
  }

  Future<void> setTimeDuration(int duration, String name,
      {bool isStop = false}) async {
    timeDurations = duration;
    totalTime += duration;
    if (!isStop) {
      if (markers.isNotEmpty) {
        markers.last.duration = duration;
        if (name.isNotEmpty) {
          markers.last.title = name;
        }
        markers.last.wind_direction = selectedWindDirection;
      }
    }

    notifyListeners();
  }

  Future<void> initLocationService() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    } catch (e) {
      debugPrint("Error while requesting location permission: $e");
    }
  }

  Future<String> getPlaceName(LatLng location) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK' && data['results'].isNotEmpty) {
      return data['results'][0]['formatted_address']; // Return first result
    } else {
      return "${location.latitude}, ${location.longitude}"; // Fallback to LatLng
    }
  }

  void toggleRouteDisplay() async {
    // isLoading = true;
    // notifyListeners();
    showAllRoutes = !showAllRoutes;
    await _updatePolylines();
    //s isLoading = false;
    notifyListeners();
  }

  bool isPolylines = false;

  Future<void> _updatePolylines() async {
    polylines.clear();

    if (showAllRoutes) {
      // Draw all routes with appropriate styling
      for (int i = 0; i < routeList.length; i++) {
        await _addRoutePolyline(routeList[i]['polyPoints'],
            i == selectedRouteIndex, i == shortestRouteIndex);
      }
    } else {
      // Draw only selected route
      await _addRoutePolyline(
          routeList[selectedRouteIndex]['polyPoints'], true, false);
    }

    // Update camera position
    if (polylines.isNotEmpty && mapController != null) {
      final points = routeList[selectedRouteIndex]['polyPoints'];
      LatLngBounds bounds = _getLatLngBounds(points);
      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  Future<void> _addRoutePolyline(
      List<LatLng> points, bool isSelected, bool isShortest) async {
    if (isSelected) {
      polylines.add(Polyline(
        polylineId: PolylineId('route_selected_border'),
        points: points,
        color: Colors.blue[900]!,
        width: 10,
      ));
      polylines.add(Polyline(
        polylineId: PolylineId('route_selected_inner'),
        points: points,
        color: Colors.blue,
        width: 6,
      ));
    } else if (isShortest) {
      polylines.add(Polyline(
        polylineId: PolylineId('route_shortest_border'),
        points: points,
        color: Colors.blue.withOpacity(0.3),
        width: 10,
      ));
      polylines.add(Polyline(
        polylineId: PolylineId('route_shortest_inner'),
        points: points,
        color: Colors.white,
        width: 6,
      ));
    } else {
      polylines.add(Polyline(
        polylineId: PolylineId('route_${points.hashCode}_border'),
        points: points,
        color: Colors.blue.withOpacity(0.3),
        width: 10,
      ));
      polylines.add(Polyline(
        polylineId: PolylineId('route_${points.hashCode}_inner'),
        points: points,
        color: Colors.white.withOpacity(0.7),
        width: 5,
      ));
    }
  }

  Future<void> fetchRouteWithWaypoints(
    List<LatLng> locations, {
    bool isRemove = false,
    bool isPathShow = false,
  }) async {
    if (locations.isEmpty || (locations.length < 2 && !isRemove)) {
      debugPrint("At least two locations are required.");
      return;
    }
    // if (routeList.isNotEmpty) {
    //   selectRoute(selectedRouteIndex); // Initialize route data
    // }
    isLoading = true;
    notifyListeners();
    routeList = [];

    try {
      List<String> placeNames = await Future.wait(locations.map(getPlaceName));
      List<List<RouteSegment>> allSegments = [];

      // Fetch routes for each segment
      for (int i = 0; i < locations.length - 1; i++) {
        String origin = placeNames[i];
        String destination = placeNames[i + 1];
        final url = 'https://maps.googleapis.com/maps/api/directions/json?'
            'origin=$origin&destination=$destination&mode=driving&'
            'alternatives=true&key=$apiKey';

        final response = await http.get(Uri.parse(url));
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK') {
          List<RouteSegment> segmentRoutes = [];
          for (var route in data['routes']) {
            final encodedPolyline = route['overview_polyline']['points'];
            final polylinePoints = _decodePolyline(encodedPolyline);
            double distance = route['legs'][0]['distance']['value'].toDouble();
            int duration = route['legs'][0]['duration']['value'];
            segmentRoutes.add(RouteSegment(
              points: polylinePoints,
              distance: distance,
              duration: duration,
              summary: route['summary'],
            ));
          }
          allSegments.add(segmentRoutes);
        } else {
          debugPrint("Error in segment $i: ${data['status']}");
          return;
        }
      }

      // Generate all possible route combinations
      routeList = _combineRouteSegments(allSegments);
      if (routeList.length > 5) {
        routeList = routeList.sublist(0, 5);
      }

      // Select the shortest route
      if (routeList.isNotEmpty) {
        selectedRouteIndex = 0;
        double shortestDistance = routeList.first['distance'];
        for (int i = 1; i < routeList.length; i++) {
          if (routeList[i]['distance'] < shortestDistance) {
            shortestDistance = routeList[i]['distance'];
            distance = shortestDistance;
            selectedRouteIndex = i;
          } else {
            distance = shortestDistance;
          }
        }
        _updatePolylines();
        if (polylines.isNotEmpty && mapController != null) {
          LatLngBounds bounds = _getLatLngBounds(polylines.first.points);
          mapController
              ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        }
      }

      if (isPathShow) showRoutesBottomSheet(context);
    } catch (e) {
      debugPrint("Error fetching routes: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Add this in your provider class

  void showRoutesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.45,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Routes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      IconButton(
                        icon: Icon(showAllRoutes
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          toggleRouteDisplay();

                          setState(() {
                            //showAllRoutes = !showAllRoutes;
                          });
                        },
                        tooltip: showAllRoutes
                            ? 'Hide other routes'
                            : 'Show all routes',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: routeList.length,
                      itemBuilder: (context, index) {
                        final route = routeList[index];
                        final isSelected = index == selectedRouteIndex;
                        final isShortest = index == shortestRouteIndex;

                        return GestureDetector(
                          onTap: () {
                            selectRoute(index);
                            // setState(() {
                            //   selectedRouteIndex = index;
                            //   distance = route['distance'];
                            // });
                            Navigator.pop(context);
                          },
                          child: Card(
                            color: isSelected
                                ? Colors.blue[50]
                                : isShortest
                                    ? Colors.green[50]
                                    : Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.blue
                                    : isShortest
                                        ? Colors.green
                                        : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              leading: isShortest
                                  ? const Icon(Icons.star, color: Colors.green)
                                  : null,
                              title: Text(
                                route['summary'] ?? 'Route ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.blue[900]
                                      : isShortest
                                          ? Colors.green[900]
                                          : Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  _buildInfoRow(
                                    Icons.directions_car,
                                    formatDistance(
                                        double.parse(
                                            route['distance'].toString()),
                                        context),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildInfoRow(
                                    Icons.access_time,
                                    _formatDuration(route['duration']),
                                  )
                                ],
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check_circle, color: Colors.blue)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  // String formatDistance(double meters, BuildContext context) {
  //   final userProvider = Provider.of<UserViewModel>(context, listen: false);

  //   if (userProvider.user.userUnit == "Miles") {
  //     double miles = meters / 1609.34; // Convert meters to miles
  //     return miles > 0.1
  //         ? '${miles.toStringAsFixed(1)} mi'
  //         : '${(miles * 5280).toStringAsFixed(0)} ft';
  //   } else {
  //     double km = meters / 1000;

  //     return km > 1 ? '${km.toStringAsFixed(1)} km' : '$meters m';
  //   }
  // }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  double calculateTotalDistanceForMap(List<LatLng> points) {
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _coordinateDistance(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  // double _coordinateDistance(
  //     double lat1, double lon1, double lat2, double lon2) {
  //   const p = 0.017453292519943295;
  //   final a = 0.5 -
  //       cos((lat2 - lat1) * p) / 2 +
  //       cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  //   return 12742 * asin(sqrt(a));
  // }

  Future<void> getPlaceSuggestions(String input, bool isStartField) async {
    isStartSuggestions = true;
    if (input.isEmpty) {
      if (isStartField) {
        startSuggestions = [];
      } else {
        destinationSuggestions = [];
      }

      return;
    }

    try {
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$kGoogleApiKey&sessiontoken=$sessionToken';
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (isStartField) {
        startSuggestions = data['predictions'] ?? [];
      } else {
        destinationSuggestions = data['predictions'] ?? [];
      }
    } catch (e) {
      debugPrint("Error while fetching suggestions: $e");
    }
    notifyListeners();
  }

  Future<void> drawPolyline() async {
    if (points.length > 1) {
      polylines.clear();
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: Colors.blue,
        width: 5,
      ));
      adjustCameraBounds();
      notifyListeners();
    }
  }

  void adjustCameraBounds() {
    if (points.isNotEmpty && mapController != null) {
      LatLngBounds bounds = _getLatLngBounds(points);
      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  double calculateTotalDistance({bool isRefresh = false}) {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    double totalDistance = 0.0;

    // for (int i = 0; i < points.length - 1; i++) {
    //   totalDistance += _coordinateDistance(
    //     points[i].latitude,
    //     points[i].longitude,
    //     points[i + 1].latitude,
    //     points[i + 1].longitude,
    //   );
    // }

    if (userProvider.user.userUnit == "KM") {
      totalDistance = totalDistance / 1000; // Convert meters to kilometers
    } else if (userProvider.user.userUnit == "Miles") {
      totalDistance = totalDistance / 1609.34; // Convert meters to miles
    }
    if (isRefresh) {
      //  distance = totalDistance;
      notifyListeners();
    }
    return totalDistance;
  }

  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (LatLng point in points) {
      if (minLat == null || point.latitude < minLat) minLat = point.latitude;
      if (maxLat == null || point.latitude > maxLat) maxLat = point.latitude;
      if (minLng == null || point.longitude < minLng) minLng = point.longitude;
      if (maxLng == null || point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
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

  Future<String> _getLocationName(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.name}, ${place.locality}, ${place.country}";
      }
    } catch (e) {
      print("Error fetching location name: $e");
    }
    return "Unknown Location";
  }

  void onRemove(LatLng position) async {
    isLoading = true;
    notifyListeners();

    points.remove(position);
    path.remove(position);

    markers.removeWhere((marker) => marker.position == position);
    mapMarkers.removeWhere((marker) => marker.position == position);
    destinationControllers.removeWhere(
      (controller) =>
          controller.text == "${position.latitude}, ${position.longitude}",
    );

    if (points.isEmpty) {
      isSave = false;
      isHurryUp = false;
      isKeyDataPoint = false;
      isTripStart = false;
      distance = 0.0;
    } else if (points.length >= 2) {
      // distance = calculateTotalDistance();
    }
    await fetchRouteWithWaypoints(path, isRemove: true);

    isLoading = false;
    notifyListeners();
  }
}
