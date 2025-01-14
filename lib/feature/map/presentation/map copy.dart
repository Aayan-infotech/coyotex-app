import 'dart:convert';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

const kGoogleApiKey = "AIzaSyDknLyGZRHAWa4s5GuX5bafBsf-WD8wd7s";

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final Set<Polyline> _polylines = {};
  final String _sessionToken = Uuid().v4();
  final LatLng _initialPosition = const LatLng(37.7749, -122.4194);
  List<dynamic> _startSuggestions = [];
  List<dynamic> _destinationSuggestions = [];
  bool isLoading = false;
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
    } on PlatformException catch (e) {
      debugPrint("PlatformException: $e");
    } catch (e) {
      debugPrint("Error while getting location: $e");
    }
  }

  Future<void> _fetchRoute() async {
    if (_startController.text.isEmpty || _destinationController.text.isEmpty) {
      _showSnackBar("Please enter both locations.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${Uri.encodeComponent(_startController.text)}&destination=${Uri.encodeComponent(_destinationController.text)}&key=$kGoogleApiKey';
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final encodedPolyline =
            data['routes'][0]['overview_polyline']['points'];
        final polylinePoints = _decodePolyline(encodedPolyline);

        // Clear previous polyline and add the new one
        setState(() {
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: polylinePoints,
            color: Colors.blue,
            width: 5,
          ));
        });

        // Adjust the camera to fit the polyline
        if (_mapController != null) {
          LatLngBounds bounds = _getLatLngBounds(polylinePoints);
          _mapController
              ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        }
      } else {
        _showSnackBar("Unable to fetch route. Please try again.");
      }
    } catch (e) {
      debugPrint("Error while fetching route: $e");
      _showSnackBar("An error occurred while fetching the route.");
    } finally {
      setState(() => isLoading = false);
    }
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

  Future<void> _getPlaceSuggestions(String input, bool isStartField) async {
    if (input.isEmpty) {
      setState(() {
        if (isStartField) {
          _startSuggestions = [];
        } else {
          _destinationSuggestions = [];
        }
      });
      return;
    }

    try {
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$kGoogleApiKey&sessiontoken=$_sessionToken';
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      setState(() {
        if (isStartField) {
          _startSuggestions = data['predictions'] ?? [];
        } else {
          _destinationSuggestions = data['predictions'] ?? [];
        }
      });
    } catch (e) {
      debugPrint("Error while fetching suggestions: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildSuggestionsBox(List<dynamic> suggestions, bool isStartField) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]['description']),
          onTap: () {
            setState(() {
              if (isStartField) {
                _startController.text = suggestions[index]['description'];
                _startSuggestions = [];
              } else {
                _destinationController.text = suggestions[index]['description'];
                _destinationSuggestions = [];
              }
            });
          },
        );
      },
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
            myLocationButtonEnabled: true,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: BrandedTextField(
                          height: 40,
                          controller: _startController,
                          labelText: 'My Location',
                          onChanged: (value) =>
                              _getPlaceSuggestions(value, true),
                          prefix: Icon(
                            Icons.location_on,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: 40, // Size of the square container
                        height: 40, // Size of the square container
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 20, // Size of the profile icon
                          color: Colors.grey, // Icon color
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: BrandedTextField(
                          height: 40,
                          controller: _startController,
                          labelText: 'Trip 1',
                          prefix: Icon(
                            Icons.location_on,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: 40, // Size of the square container
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white, // Size of the square container

                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.drag_handle,
                          size: 20, // Size of the profile icon
                          color: Colors.grey, // Icon color
                        ),
                      )
                    ],
                  )
                  // Card(
                  //   elevation: 4,
                  //   child: Column(
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: _buildTextField(
                  //             _startController, 'Current Location', true),
                  //       ),
                  //       _buildSuggestionsBox(_startSuggestions, true),
                  //       Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: _buildTextField(
                  //             _destinationController, 'Destination', false),
                  //       ),
                  //       _buildSuggestionsBox(_destinationSuggestions, false),
                  //       Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  //         child: ElevatedButton(
                  //           onPressed: isLoading ? null : _fetchRoute,
                  //           child: isLoading
                  //               ? const CircularProgressIndicator()
                  //               : const Text('Plan Trip'),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Distance',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('12 km')
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Set Time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('145 min')
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Weather',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('22°C, Great Weather')
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Wind',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('5 km/h')
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Let\'s Hunt'),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Save Trip'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
