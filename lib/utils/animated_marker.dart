import 'dart:math';

import 'package:animated_marker/animated_marker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<LatLng>? locationStream;

  final List<LatLng> mockPositionsStatic = [
    const LatLng(37.75483, -122.42942),
    const LatLng(37.75551, -122.41106),
  ];

  @override
  void initState() {
    super.initState();
    _initLocationStream();
  }

  Future<void> _initLocationStream() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return; // Handle permission denial
    }

    setState(() {
      locationStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).map((position) => LatLng(position.latitude, position.longitude));
    });
  }

  @override
  Widget build(BuildContext context) {
    final staticMarkers = {
      for (int i = 0; i < mockPositionsStatic.length; i++)
        Marker(
          markerId: MarkerId('static-$i'),
          position: mockPositionsStatic[i],
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'Static Marker $i',
            onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Static Marker $i'),
              ),
            ),
          ),
        ),
    };

    if (locationStream == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: StreamBuilder<LatLng>(
        stream: locationStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final userLocation = snapshot.data!;

          final markers = {
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: userLocation,
              rotation: Random().nextDouble() * 360,
              infoWindow: InfoWindow(
                title: 'You are here',
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => const AlertDialog(
                    title: Text('Current Location'),
                  ),
                ),
              ),
            )
          };

          return AnimatedMarker(
            staticMarkers: staticMarkers,
            animatedMarkers: markers,
            duration: const Duration(seconds: 3),
            curve: Curves.easeOut,
            builder: (context, animatedMarkers) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: userLocation,
                  zoom: 16,
                ),
                markers: animatedMarkers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              );
            },
          );
        },
      ),
    );
  }
}
