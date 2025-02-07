import 'package:coyotex/core/services/api_base.dart';
import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/model/pref_model.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TripAPIs extends ApiBase {
  TripAPIs() : super();
  final String apiKey = '7a698daa9a39296bb22dfac21380b303';
  Future<ApiResponseWithData<Map<String, dynamic>>> addTrip(
      TripModel trip_model) async {
    Map<String, dynamic> data = trip_model.toJson();

    print(jsonEncode(data));

    return await CallHelper().postWithData('api/trips/', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> addStop(
      MarkerData markerData, String id) async {
    Map<String, dynamic> data = markerData.toJson();

    return await CallHelper()
        .postWithData('api/trips/${id}/add-marker', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> addWayPoints(
      String id, List<String> lstWayPoints) async {
    Map<String, dynamic> data = {"waypoints": lstWayPoints};

    return await CallHelper()
        .postWithData('api/trips/${id}/add-waypoint', data, {});
  }

  Future<ApiResponse> addAnimalSeenAndKilled(Map<String, dynamic> data) async {
    return await CallHelper().patch(
      
      'trips/update-animals',
      data,
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> addPoint(
      String id, List<Map<String, dynamic>> points) async {
    Map<String, dynamic> data = {"routePoints": points};

    return await CallHelper()
        .postWithData('api/trips/${id}/add-route-point', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getUserTrip() async {
    return await CallHelper().getWithData('api/trips/', {});
  }

  final String endPoint = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final String finalUrl =
        '$endPoint?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

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

  Future<ApiResponse> updateProfile(String name, String number, String userUnit,
      String userWeatherPref) async {
    Map<String, String> data = {
      "name": name,
      "number": number,
      "userUnit": userUnit,
      "userWeatherPref": userWeatherPref
    };

    return await CallHelper().post(
      'api/update-details',
      data,
    );
  }
}
