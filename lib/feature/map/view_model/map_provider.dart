import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../data/trip_model.dart';

class MapProvider with ChangeNotifier {
  final TextEditingController startController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final List<TextEditingController> destinationControllers = [];

  final Set<Polyline> polylines = {};
  final Set<Marker> markers = {};
  final List<LatLng> points = [];
  final String sessionToken = Uuid().v4();
  var kGoogleApiKey = "AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s";

  
   List<dynamic> startSuggestions = [];
  List<dynamic> destinationSuggestions = [];
  GoogleMapController? mapController;
  final LatLng initialPosition = const LatLng(37.7749, -122.4194);

  LatLng? pointA;
  LatLng? pointB;
  bool isSave = false;
  bool isLoading = false;
  double distance = 0.0;

  final String apiKey = "AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s";

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

  Future<void> fetchRoute() async {
    if (startController.text.isEmpty || destinationController.text.isEmpty) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${Uri.encodeComponent(startController.text)}&destination=${Uri.encodeComponent(destinationController.text)}&key=$apiKey';
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final encodedPolyline =
            data['routes'][0]['overview_polyline']['points'];
        final polylinePoints = _decodePolyline(encodedPolyline);

        polylines.clear();
        polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ));
        notifyListeners();

        if (mapController != null) {
          LatLngBounds bounds = _getLatLngBounds(polylinePoints);
          mapController
              ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        }
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPlaceSuggestions(String input, bool isStartField) async {
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
  }

  void onMapTapped(LatLng position) {
    points.add(position);

    if (points.length == 1) {
      startController.text = "${position.latitude}, ${position.longitude}";
    } else {
      final controller = TextEditingController(
        text: "${position.latitude}, ${position.longitude}",
      );
      destinationControllers.add(controller);
    }

    if (points.length >= 2) {
      distance = _calculateTotalDistance();
      isSave = true;
    }

    markers.add(Marker(
      markerId: MarkerId('Point ${points.length}'),
      position: position,
      infoWindow: InfoWindow(
        title: 'Point ${points.length}',
        snippet: '${position.latitude}, ${position.longitude}',
      ),
    ));
    drawPolyline();
    notifyListeners();
  }

  void drawPolyline() {
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

  double _calculateTotalDistance() {
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
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
}
