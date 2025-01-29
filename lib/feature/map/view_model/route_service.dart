import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


class RouteService {
  final String apiKey;

  RouteService(this.apiKey);

  Future<List<LatLng>> fetchRoute(String start, String end) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${Uri.encodeComponent(start)}&destination=${Uri.encodeComponent(end)}&mode=driving&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      final encodedPolyline = data['routes'][0]['overview_polyline']['points'];
      return _decodePolyline(encodedPolyline);
    } else {
      throw Exception('Failed to fetch route: ${data['status']}');
    }
  }

  Future<List<LatLng>> fetchRouteWithWaypoints(List<LatLng> locations) async {
    if (locations.isEmpty || locations.length < 2) {
      throw Exception('At least two locations are required.');
    }

    String waypoints = locations
        .skip(1)
        .map((location) => '${location.latitude},${location.longitude}')
        .join('|');

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${locations.first.latitude},${locations.first.longitude}&destination=${locations.last.latitude},${locations.last.longitude}&waypoints=$waypoints&mode=driving&avoid=highways&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      final encodedPolyline = data['routes'][0]['overview_polyline']['points'];
      return _decodePolyline(encodedPolyline);
    } else {
      throw Exception('Failed to fetch route: ${data['status']}');
    }
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