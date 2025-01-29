import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/view_model/location_service.dart';
import 'package:coyotex/feature/map/view_model/route_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';


import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapProvider with ChangeNotifier {
  final RouteService _routeService = RouteService("AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s");
  final LocationService _locationService = LocationService();

  final TextEditingController startController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final List<TextEditingController> destinationControllers = [];
  final List<TripModel> trips = [];
  final Set<Polyline> polylines = {};
  final Set<Marker> markers = {};
  List<LatLng> points = [];
  List<LatLng> path = [];

  GoogleMapController? mapController;
  LatLng initialPosition = const LatLng(26.862421770613125, 80.99804357972356);
  bool isLoading = false;
  double distance = 0.0;
  bool isTripStart = false;
  bool isSave = false;
  bool isHurryUp = false;
  bool isKeyDataPoint = false;

  Future<void> letsHunt() async {
    isTripStart = true;
    isLoading = true;
    notifyListeners();

    try {
      Position initialPosition = await _locationService.getCurrentLocation();
      path.add(LatLng(initialPosition.latitude, initialPosition.longitude));
      await _routeService.fetchRouteWithWaypoints(path);

      _locationService.getPositionStream().listen((position) {
        notifyListeners();
      });

      isLoading = false;
    } catch (e) {
      isLoading = false;
      debugPrint('Error: $e');
    }
    notifyListeners();
  }

  Future<void> addStop() async {
    try {
      isLoading = true;
      notifyListeners();

      Position currentPosition = await _locationService.getCurrentLocation();
      LatLng currentStop = LatLng(currentPosition.latitude, currentPosition.longitude);

      points.add(currentStop);
      path.add(currentStop);

      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      markers.add(Marker(
        markerId: MarkerId(uniqueId),
        position: currentStop,
        infoWindow: InfoWindow(
          title: 'Stop ${points.length}',
          snippet: '${currentStop.latitude}, ${currentStop.longitude}',
        ),
      ));

      await _routeService.fetchRouteWithWaypoints(path);
      distance = _calculateTotalDistance();
      isSave = false;
    } catch (e) {
      debugPrint("Error while adding a stop: $e");
    } finally {
      isLoading = false;
      notifyListeners();
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
    return totalDistance / 1000;
  }

  void saveTrip() {
    if (points.isEmpty) {
      debugPrint("Cannot save trip. Please ensure all fields are filled.");
      return;
    }

    final trip = TripModel(
timeDurations:{},
      id:  Uuid().v4(),
      name: 'Trip ${trips.length + 1}',
      startLocation: startController.text,
      destination: destinationController.text,
      waypoints: destinationControllers.map((c) => c.text).toList(),
      totalDistance: distance,
      createdAt: DateTime.now(),
      routePoints: List.from(points),
      markers: markers.map((marker) {
        return MarkerData(
          id: marker.markerId.value,
          position: marker.position,
          title: marker.infoWindow.title ?? '',
          snippet: marker.infoWindow.snippet ?? '',
        );
      }).toList(),
    );

    trips.add(trip);
    resetFields();
    notifyListeners();
  }

  void resetFields() {
    startController.clear();
    destinationController.clear();
    destinationControllers.clear();
    points.clear();
    path.clear();
    polylines.clear();
    markers.clear();
    isSave = false;
    distance = 0.0;
    notifyListeners();
  }
}