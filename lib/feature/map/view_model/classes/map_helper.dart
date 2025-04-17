import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapHelper {
  Future<int> calculateTravelTime(
      List<LatLng> coordinates, String apiKey) async {
    if (coordinates.length < 2) return 0;

    final origins = coordinates.sublist(0, coordinates.length - 1);
    final destinations = coordinates.sublist(1);

    final apiUrl = _buildRequestUrl(origins, destinations, apiKey);
    final response = await _makeApiRequest(apiUrl);
    return _parseTotalDuration(response, origins.length);
  }

  Uri _buildRequestUrl(
      List<LatLng> origins, List<LatLng> destinations, String apiKey) {
    const baseUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    final originsParam = _formatCoordinates(origins);
    final destinationsParam = _formatCoordinates(destinations);

    return Uri.parse('$baseUrl?'
        'origins=$originsParam'
        '&destinations=$destinationsParam'
        '&key=$apiKey');
  }

  String _formatCoordinates(List<LatLng> coordinates) {
    return coordinates
        .map((coord) => '${coord.latitude},${coord.longitude}')
        .join('|');
  }

  Future<Map<String, dynamic>> _makeApiRequest(Uri url) async {
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  int _parseTotalDuration(Map<String, dynamic> response, int expectedPairs) {
    if (response['status'] != 'OK') {
      throw Exception(
          'API Error: ${response['error_message'] ?? 'Unknown error'}');
    }

    int totalDuration = 0;
    final rows = response['rows'] as List;

    for (int i = 0; i < rows.length; i++) {
      final elements = rows[i]['elements'] as List;
      final element = elements[i];

      if (element['status'] != 'OK') {
        throw Exception('Route error between points $i and ${i + 1}');
      }

      totalDuration += element['duration']['value'] as int;
    }

    return totalDuration;
  }
  
}


