import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _startController = TextEditingController();
  final List<TextEditingController> _destinationControllers = [];
  final Set<Polyline> _polylines = {};
  final String _sessionToken = const Uuid().v4();
  final LatLng _initialPosition = const LatLng(37.7749, -122.4194);
  final List<LatLng> _points = [];
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return; // Permission denied
        }
      }
    } catch (e) {
      debugPrint("Error while getting location: $e");
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _points.add(position);

      if (_points.length == 1) {
        _startController.text = "${position.latitude}, ${position.longitude}";
      } else {
        final controller = TextEditingController(
          text: "${position.latitude}, ${position.longitude}",
        );
        _destinationControllers.add(controller);
      }

      _drawPolyline();
    });
  }

  void _drawPolyline() {
    if (_points.length > 1) {
      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: _points,
          color: Colors.blue,
          width: 5,
        ));
      });
      _adjustCameraBounds();
    }
  }

  void _adjustCameraBounds() {
    if (_points.isNotEmpty) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
          _points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
        ),
        northeast: LatLng(
          _points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
          _points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
        ),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    bool enabled,
    Icon prefixIcon,
    Icon suffixIcon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 10,
            ),
            myLocationEnabled: true,
            mapType: MapType.satellite,
            myLocationButtonEnabled: false,
           
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTapped,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  _buildTextField(
                    _startController,
                    'Start Location',
                    true,
                    const Icon(Icons.location_on, size: 20),
                    const Icon(Icons.person, size: 20, color: Colors.grey),
                  ),
                  ..._destinationControllers.map((controller) {
                    return _buildTextField(
                      controller,
                      'Waypoint',
                      false,
                      const Icon(Icons.check, color: Colors.green, size: 20),
                      const Icon(Icons.drag_handle, size: 20, color: Colors.black),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
