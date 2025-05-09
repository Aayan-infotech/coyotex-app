import 'package:coyotex/core/services/api_base.dart';
import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';

import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TripAPIs extends ApiBase {
  TripAPIs() : super();
  final String apiKey = '7a698daa9a39296bb22dfac21380b303';
  Future<ApiResponseWithData<Map<String, dynamic>>> addTrip(
      TripModel tripModel) async {
    Map<String, dynamic> data = tripModel.toJson();

    return await CallHelper().postWithData('trips/', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> addStop(
      MarkerData markerData, String id) async {
    Map<String, dynamic> data = markerData.toJson();

    return await CallHelper().postWithData('trips/$id/add-marker', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> updateTrip(
      String tripId) async {
    Map<String, dynamic> data = {"tripId": tripId};

    return await CallHelper()
        .postWithData('trips/trip/update-trip-status', data, {});
  }

  Future<ApiResponse> deleteTrip(String id) async {
    return await CallHelper().delete(
      'trips/$id',
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> addWayPoints(
      String id, List<String> lstWayPoints) async {
    Map<String, dynamic> data = {"waypoints": lstWayPoints};

    return await CallHelper().postWithData('trips/$id/add-waypoint', data, {});
  }

  Future<ApiResponse> addAnimalSeenAndKilled(
      MarkerData markerData, String tripId) async {
    Map<String, dynamic> data = {
      "tripId": tripId,
      "markerId": markerData.id,
      "animalSeen": markerData.animalSeen,
      "animalKilled": markerData.animalKilled,
      "wind_speed": '',
      "wind_degree": markerData.wind_degree,
      "wind_direction": markerData.wind_direction
    };
    return await CallHelper().patch(
      'trips/update-animals',
      data,
    );
  }

  Future<ApiResponse> deleteMarker(String markerId, String tripId) async {
    return await CallHelper().delete(
      'trips/delete-marker/$tripId/$markerId',
    );
  }

  Future<ApiResponse> deleteWayPoints(LatLng latLang, String tripId) async {
    Map<String, dynamic> data = {
      "latitude": latLang.latitude,
      "longitude": latLang.longitude
    };
    return await CallHelper()
        .deleteWithBody('trips/$tripId/remove-route-point', data);
  }

  Future<ApiResponse> isVisited(
    String tripId,
    String markerId,
  ) async {
    Map<String, dynamic> data = {
      "tripId": tripId,
      "markerId": markerId,
      "is_visited": true
    };
    return await CallHelper().patch(
      'trips/update-animals',
      data,
    );
  }

  Future<http.Response?> generateTripPDF(String tripId) async {
    final String url = '${CallHelper.baseUrl}trips/generate-trip-pdf/$tripId';
    String accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/pdf',
        },
      );

      if (response.statusCode == 200) {
        print('PDF generated successfully.');
        return response;
      } else {
        print('Failed to generate PDF: ${response.statusCode}');
        return response;
      }
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> addPoint(
      String id, List<Map<String, dynamic>> points) async {
    Map<String, dynamic> data = {"routePoints": points};

    return await CallHelper()
        .postWithData('trips/$id/add-route-point', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> addWeatherMarker(
      String id, WeatherMarker weatherMarker) async {
    Map<String, dynamic> data = weatherMarker.toJson();

    return await CallHelper()
        .postWithData('trips/$id/add-weather-marker', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getUserTrip() async {
    return await CallHelper().getWithData('trips/', {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> generateGpx(
      String tripId) async {
    return await CallHelper().getWithData('trips/${tripId}/gpx', {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getTripId(String id) async {
    return await CallHelper().getWithData('trips/$id', {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getAllMarker() async {
    return await CallHelper().getWithData('trips/trip/user-markers', {});
  }

  final String endPoint = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final String finalUrl =
        '$endPoint?lat=$lat&lon=$lon&appid=$apiKey&units=imperial';

    try {
      final response = await http.get(Uri.parse(finalUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load weather data');
    }
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> searchTrips(
      String query, int page, int limit) async {
    final Map<String, String> params = {
      'query': query,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    return await CallHelper()
        .getWithData('trips/trip/search', {}, queryParams: params);
  }

  Future<ApiResponse> updateProfile(String name, String number, String userUnit,
      String userWeatherPref) async {
    Map<String, String> data = {
      "name": name,
      "number": number,
      "userUnit": userUnit,
      "userWeatherPref": userWeatherPref
    };

    return await CallHelper().post(
      'update-details',
      data,
    );
  }
}
