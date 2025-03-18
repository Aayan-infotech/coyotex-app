import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RouteProvider with ChangeNotifier {
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  double _distance = 0.0;
  int _duration = 0;

  Set<Polyline> get polylines => _polylines;
  List<LatLng> get routePoints => _routePoints;
  double get distance => _distance;
  int get duration => _duration;

  Future<void> calculateRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return;
    
    final url = _buildDirectionsUrl(waypoints);
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _processRouteData(data);
    } else {
      throw Exception('Failed to load route');
    }
  }

  Uri _buildDirectionsUrl(List<LatLng> waypoints) {
    final origin = waypoints.first;
    final destination = waypoints.last;
    final waypointsParam = waypoints.length > 2 
      ? '&waypoints=${waypoints.sublist(1, waypoints.length-1).map((p) => '${p.latitude},${p.longitude}').join('|')}'
      : '';

    return Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '$waypointsParam'
      '&key=YOUR_API_KEY'
    );
  }

  void _processRouteData(Map<String, dynamic> data) {
    _polylines.clear();
    _routePoints.clear();
    
    if (data['status'] == 'OK') {
      final points = data['routes'][0]['overview_polyline']['points'];
      _routePoints = _decodePolyline(points);
      
      _distance = data['routes'][0]['legs'].fold(0.0, (sum, leg) => 
        sum + leg['distance']['value']);
      _duration = data['routes'][0]['legs'].fold(0, (sum, leg) => 
        sum + leg['duration']['value']);
      
      _polylines.add(Polyline(
        polylineId: const PolylineId('main_route'),
        points: _routePoints,
        color: Colors.blue,
        width: 5,
      ));
    }
    
    notifyListeners();
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
  List<Map<String, dynamic>> combineRouteSegments(
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

}
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