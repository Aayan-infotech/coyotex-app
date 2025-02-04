import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripModel {
  final String id;
  final String name;
  final String startLocation;
  final String destination;
  final List<String> waypoints;
  final double totalDistance;
  final DateTime createdAt;
  final List<LatLng> routePoints;
  final List<MarkerData> markers;

  TripModel({
    required this.id,
    required this.name,
    required this.startLocation,
    required this.destination,
    required this.waypoints,
    required this.totalDistance,
    required this.createdAt,
    required this.routePoints,
    required this.markers,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      name: json['name'],
      startLocation: json['startLocation'],
      destination: json['destination'],
      waypoints: List<String>.from(json['waypoints']),
      totalDistance: json['totalDistance'],
      createdAt: DateTime.parse(json['createdAt']),
      routePoints: (json['routePoints'] as List)
          .map((e) => LatLng(e['latitude'], e['longitude']))
          .toList(),
      markers:
          (json['markers'] as List).map((e) => MarkerData.fromJson(e)).toList(),

    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startLocation': startLocation,
      'destination': destination,
      'waypoints': waypoints,
      'totalDistance': totalDistance,
      'createdAt': createdAt.toIso8601String(),
      'routePoints': routePoints
          .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
          .toList(),
      'markers': markers.map((e) => e.toJson()).toList(),

    };
  }
}

class MarkerData {
  final String id;
  final LatLng position;
  final String title;
  final String snippet;
  String markerType;
  int duration;
  String icon;

  MarkerData({
    required this.icon,
    required this.id,
    required this.position,
    required this.title,
    required this.snippet,
    required this.markerType,
    required this.duration
  });

  factory MarkerData.fromJson(Map<String, dynamic> json) {
    return MarkerData(
      icon: json["icon"],
      id: json['id'],
      position: LatLng(json['latitude'], json['longitude']),
      title: json['title'],
      snippet: json['snippet'],
      markerType: json['markerType'],
      duration: json['duration']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'title': title,
      'snippet': snippet,
      "icon": icon,
      "timeDurations": duration,
      "markerType": "start"
    };
  }
}
