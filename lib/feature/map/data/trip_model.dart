import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripModel {
  final String id;
  final String userId;
  final String name;
  final String startLocation;
  final String destination;
  final List<String> waypoints;
  final double totalDistance;
  final DateTime createdAt;
  final List<LatLng> routePoints;
  final List<MarkerData> markers;
  final List<WeatherMarker> weatherMarkers;
  final List<String> images;
  int animalKilled;
  int animalSeen;
  String tripStatus;

  TripModel({
    required this.tripStatus,
    required this.id,
    required this.userId,
    required this.name,
    required this.startLocation,
    required this.destination,
    required this.waypoints,
    required this.totalDistance,
    required this.createdAt,
    required this.routePoints,
    required this.markers,
    required this.weatherMarkers,
    required this.animalKilled,
    required this.animalSeen,
    required this.images,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      tripStatus: json["tripStatus"] ?? 'created',
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      startLocation: json['startLocation'] ?? '',
      destination: json['destination'] ?? '',
      waypoints: List<String>.from(json['waypoints'] ?? []),
      totalDistance: (json['totalDistance'] ?? 0).toDouble(),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      routePoints: (json['routePoints'] as List?)
              ?.map((e) => LatLng(e['latitude'], e['longitude']))
              .toList() ??
          [],
      markers: (json['markers'] as List?)
              ?.map((e) => MarkerData.fromJson(e))
              .toList() ??
          [],
      weatherMarkers: (json['weatherMarkers'] as List?)
              ?.map((e) => WeatherMarker.fromJson(e))
              .toList() ??
          [],
      animalKilled: json['animalsKilled'] ?? 0,
      animalSeen: json['animalsSeen'] ?? 0,
      images: List<String>.from(json['photos'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
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
      'weatherMarkers': weatherMarkers.map((e) => e.toJson()).toList(),
      // 'animalsKilled': animalKilled,
      // 'animalsSeen': animalSeen,
      // 'photos': images,
    };
  }
}

class MarkerData {
  final String id;
  final LatLng position;
  String title;
  final String snippet;
  final String icon;
  final String markerType;
  int duration;
  String animalKilled;
  String animalSeen;
  int wind_degree;
  String wind_direction;
  List<dynamic>? media;

  MarkerData(
      {required this.id,
      required this.position,
      required this.title,
      required this.snippet,
      required this.icon,
      required this.markerType,
      required this.duration,
      required this.animalKilled,
      required this.animalSeen,
      required this.wind_degree,
      required this.wind_direction,
      this.media});

  factory MarkerData.fromJson(Map<String, dynamic> json) {
    return MarkerData(
        animalKilled: json["animalKilled"] ?? '0',
        animalSeen: json["animalSeen"] ?? '0',
        wind_degree: 0, //json["wind_degree"] ?? '',
        wind_direction: json["wind_direction"] ?? "",
        id: json['_id'] ?? "",
        position: LatLng(json['latitude'] ?? 0, json['longitude'] ?? 0),
        title: json['title'] ?? '',
        snippet: json['snippet'] ?? "",
        icon: json['icon'] ?? '',
        markerType: json['markerType'] ?? "inbetween",
        duration: json['timeDurations'] ?? 0,
        media: json["mediaFiles"] ?? []);
  }
  

  Map<String, dynamic> toJson() {
    return {
      //  '_id': id,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'title': title,
      'snippet': snippet,
      'icon': icon,
      'animalKilled': animalKilled,
      'animalSeen': animalSeen,
      'wind_direction': wind_direction,
      'timeDurations': duration,
      'markerType': markerType,
    };
  }
}

class WeatherMarker {
  final Weatherlocation location;
  final WeatherData weather;

  WeatherMarker({required this.location, required this.weather});

  factory WeatherMarker.fromJson(Map<String, dynamic> json) {
    return WeatherMarker(
      location: Weatherlocation.fromJson(json['location']),
      weather: WeatherData.fromJson(json['weather']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'weather': weather.toJson(),
    };
  }
}

class Weatherlocation {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final int timezone;

  Weatherlocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  factory Weatherlocation.fromJson(Map<String, dynamic> json) {
    return Weatherlocation(
      name: json['name'],
      country: json['country'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      timezone: json['timezone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }
}

class WeatherData {
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final int visibility;
  final double windSpeed;
  final int windDegree;
  final double windGust;
  final int cloudiness;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final int sunrise;
  final int sunset;
  final int recordedAt;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.visibility,
    required this.windSpeed,
    required this.windDegree,
    required this.windGust,
    required this.cloudiness,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.sunrise,
    required this.sunset,
    required this.recordedAt,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feels_like'] as num?)?.toDouble() ?? 0.0,
      tempMin: (json['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (json['temp_max'] as num?)?.toDouble() ?? 0.0,
      pressure: json['pressure'] as int? ?? 0,
      humidity: json['humidity'] as int? ?? 0,
      visibility: json['visibility'] as int? ?? 0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      windDegree: json['wind_degree'] as int? ?? 0,
      windGust: (json['wind_gust'] as num?)?.toDouble() ?? 0.0,
      cloudiness: json['cloudiness'] as int? ?? 0,
      weatherMain: json['weather_main'] as String? ?? '',
      weatherDescription: json['weather_description'] as String? ?? '',
      weatherIcon: json['weather_icon'] as String? ?? '',
      sunrise: json['sunrise'] as int? ?? 0,
      sunset: json['sunset'] as int? ?? 0,
      recordedAt: json['recorded_at'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feels_like': feelsLike,
      'temp_min': tempMin,
      'temp_max': tempMax,
      'pressure': pressure,
      'humidity': humidity,
      'visibility': visibility,
      'wind_speed': windSpeed,
      'wind_degree': windDegree,
      'wind_gust': windGust,
      'cloudiness': cloudiness,
      'weather_main': weatherMain,
      'weather_description': weatherDescription,
      'weather_icon': weatherIcon,
      'sunrise': sunrise,
      'sunset': sunset,
      'recorded_at': recordedAt,
    };
  }
}
