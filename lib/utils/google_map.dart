import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(37.7749, -122.4194); // Default to San Francisco
  late Marker _userMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _updateMarker();
        _mapController.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
      });
    });
  }

  void _updateMarker() {
    _userMarker = Marker(
      markerId: const MarkerId("user_location"),
      position: _currentPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Google Map Moving Pointer")),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: 15,
          ),
          markers: {_userMarker},
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _updateMarker();
          },
        ),
      ),
    );
  }
}
