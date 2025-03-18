import 'dart:io';

import 'package:coyotex/core/services/server_calls/trip_apis.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/core/services/api_base.dart'; // Ensure required imports
import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class TripViewModel extends ChangeNotifier {
  final TripAPIs _tripAPIs = TripAPIs();
  List<MarkerData> lstMarker = [];

  Future<ApiResponseWithData<Map<String, dynamic>>> addTrip(
      TripModel tripModel) async {
    return await _tripAPIs.addTrip(tripModel);
  }

  Future<ApiResponseWithData> getAllMarker() async {
    var response = await _tripAPIs.getAllMarker();
    if (response.success) {
      lstMarker = (response.data["markers"] as List)
          .map((item) => MarkerData.fromJson(item))
          .toList();
    
    } else {
      lstMarker = [];
    }
    return response;
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> addStop(
      MarkerData markerData, String id) async {
    return await _tripAPIs.addStop(markerData, id);
  }

  Future<ApiResponse> deleteTrip(String id, BuildContext context) async {
    var response = await _tripAPIs.deleteTrip(id);
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    if (response.success) {
      await mapProvider.getTrips();
      AppDialog.showSuccessDialog(context, response.message, () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      });
    } else {
      AppDialog.showErrorDialog(context, response.message, () {
        Navigator.of(context).pop();
      });
    }
    return response;
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> addWayPoints(
      String id, List<String> lstWayPoints) async {
    return await _tripAPIs.addWayPoints(id, lstWayPoints);
  }

  Future<ApiResponse> addAnimalSeenAndKilled(
      MarkerData markerData, String tripId) async {
    return await _tripAPIs.addAnimalSeenAndKilled(markerData, tripId);
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> addPoint(
      String id, List<Map<String, dynamic>> points) async {
    return await _tripAPIs.addPoint(id, points);
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getUserTrip() async {
    return await _tripAPIs.getUserTrip();
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getTripById(
      String id) async {
    return await _tripAPIs.getTripId(id);
  }

  Future<http.Response?> generateTripPDF(String tripId) async {
    return await _tripAPIs.generateTripPDF(tripId);
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> updateUserTrip(
      String id) async {
    return await _tripAPIs.updateTrip(id);
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> searchTrip(
      String query, int page, int limit) async {
    return await _tripAPIs.searchTrips(query, page, limit);
  }

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    return await _tripAPIs.getWeather(lat, lon);
  }

  Future<ApiResponse> updateProfile(String name, String number, String userUnit,
      String userWeatherPref) async {
    return await _tripAPIs.updateProfile(
        name, number, userUnit, userWeatherPref);
  }
}
