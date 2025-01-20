import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripModel {
  final String id;
  final String startLocation;
  final String endLocation;
  final List<LatLng> waypoints;
  final double totalDistance;
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.waypoints,
    required this.totalDistance,
    required this.createdAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      startLocation: json['startLocation'],
      endLocation: json['endLocation'],
      waypoints: (json['waypoints'] as List)
          .map((point) => LatLng(point['latitude'], point['longitude']))
          .toList(),
      totalDistance: json['totalDistance'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'waypoints': waypoints
          .map((point) => {'latitude': point.latitude, 'longitude': point.longitude})
          .toList(),
      'totalDistance': totalDistance,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
