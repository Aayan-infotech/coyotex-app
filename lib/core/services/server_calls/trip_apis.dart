import 'package:coyotex/core/services/api_base.dart';
import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/model/pref_model.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TripAPIs extends ApiBase {
  TripAPIs() : super();
  final String apiKey = '7a698daa9a39296bb22dfac21380b303';
  Future<ApiResponseWithData<Map<String, dynamic>>> addTrip(
      TripModel trip_model) async {
    Map<String, dynamic> data = trip_model.toJson();
    print(data);

    return await CallHelper().postWithData('api/trips/', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getUserTrip(
      TripModel trip_model) async {
    Map<String, dynamic> data = trip_model.toJson();
    print(data);

    return await CallHelper().postWithData('api/trips/${userId}', data, {});
  }

  // Endpoint for weather API
  final String endPoint = 'https://api.openweathermap.org/data/2.5/weather';

  // Fetch weather data based on latitude and longitude
  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    // Construct the final endpoint URL
    final String finalUrl =
        '$endPoint?lat=$lat&lon=$lon&appid=$apiKey&units=metric'; // `units=metric` for Celsius

    try {
      // Make the HTTP GET request
      final response = await http.get(Uri.parse(finalUrl));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        return json.decode(response.body);
      } else {
        // If the server returns an error, throw an exception
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      // Handle errors like no internet connection
      print('Error: $e');
      throw Exception('Failed to load weather data');
    }
  }
}
