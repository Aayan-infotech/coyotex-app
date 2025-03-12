import 'dart:convert';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class DistanceDialogue extends StatefulWidget {
  final List<MarkerData> markers;

  const DistanceDialogue({
    Key? key,
    required this.markers,
  }) : super(key: key);

  @override
  _DistanceDialogueState createState() => _DistanceDialogueState();
}

class _DistanceDialogueState extends State<DistanceDialogue> {
  final Color _primaryColor = Colors.blue.shade800;
  final Color _accentColor = Colors.teal.shade600;
  final Color _backgroundColor = Colors.grey.shade100;
  bool isLoading = false;

  List<double> segmentDistances = [];
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchDistancesFromAPI();
  }

  Future<void> _fetchDistancesFromAPI() async {
    setState(() {
      isLoading = true;
    });
    final markers = widget.markers;
    segmentDistances.clear();
    totalDistance = 0.0;

    if (markers.length < 2) return;

    for (int i = 0; i < markers.length - 1; i++) {
      double distance = await getDistanceBetween(
        markers[i].position.latitude,
        markers[i].position.longitude,
        markers[i + 1].position.latitude,
        markers[i + 1].position.longitude,
      );
      segmentDistances.add(distance);
      totalDistance += distance;
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<double> getDistanceBetween(
      double lat1, double lon1, double lat2, double lon2) async {
    String apiKey = "AIzaSyDg2wdDb3SFR1V_3DO2mNVvc01Dh6vR5Mc";
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$lat1,$lon1&destination=$lat2,$lon2&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        double distanceMeters =
            data['routes'][0]['legs'][0]['distance']['value'].toDouble();
        return distanceMeters / 1000; // Convert meters to km
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final markers = widget.markers;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: isLoading
          ? CircularProgressIndicator.adaptive()
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.zoom_out_map, color: _primaryColor, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      "Journey Overview",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: _primaryColor.withOpacity(0.3), thickness: 1.5),
                const SizedBox(height: 16),
                if (markers.length < 2)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Add at least two points to see route details',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  _buildRouteVisualization(markers),
                const SizedBox(height: 16),
                _buildTotalSection(),
              ],
            ),
    );
  }

  Widget _buildRouteVisualization(List<MarkerData> markers) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: markers.length * 2 - 1,
        itemBuilder: (context, index) {
          int markerIndex = index ~/ 2;
          if (index.isEven) {
            return _buildMarkerPoint(markerIndex, markers[markerIndex]);
          } else {
            return _buildConnectionLine(segmentDistances[markerIndex]);
          }
        },
      ),
    );
  }

  Widget _buildMarkerPoint(int index, MarkerData marker) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _accentColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            marker.snippet ?? 'Point ${index + 1}',
            textAlign: TextAlign.center,
            maxLines: 3,
            style: TextStyle(
              color: _primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionLine(double distance) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 2,
            color: _accentColor,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${distance.toStringAsFixed(2)} km",
              style: TextStyle(
                color: _accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Distance',
              style: TextStyle(
                  color: _primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            "${totalDistance.toStringAsFixed(2)} km",
            style: TextStyle(
                color: _accentColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
