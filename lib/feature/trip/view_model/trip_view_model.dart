import 'package:coyotex/core/services/model/notification_model.dart';
import 'package:coyotex/core/services/server_calls/trip_apis.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
// Ensure required imports
import 'package:coyotex/core/services/call_halper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class TripViewModel extends ChangeNotifier {
  final TripAPIs _tripAPIs = TripAPIs();
  List<MarkerData> lstMarker = [];
  List<MarkerData> lstAllMarker = [];

  Future<ApiResponseWithData<Map<String, dynamic>>> addTrip(
      TripModel tripModel) async {
    return await _tripAPIs.addTrip(tripModel);
  }

  void showFinishWarningDialog(MapProvider provider, BuildContext context) {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false; // Declare isLoading outside StatefulBuilder

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Finish Trip"),
              content: isLoading
                  ? const SizedBox(
                      height: 50,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const Text("Are you sure you want to finish the trip?"),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          final tripProvider = Provider.of<TripViewModel>(
                              context,
                              listen: false);

                          var response = await userProvider.sendNotifications(
                            "Trip Update",
                            "Your Trip has been Completed",
                            NotificationType.tripUpdate,
                            mapProvider.selectedTripModel.id,
                          );
                          if (response.success) {
                            var response = await tripProvider.updateUserTrip(
                                mapProvider.selectedTripModel.id);
                            if (response.success) {
                              await tripProvider.getUserTrip();
                            }
                          }

                          provider.resetFields();
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            //if (widget.isRestart!) Navigator.pop(context);
                          }
                        },
                  child: const Text("Finish"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<ApiResponseWithData> getAllMarker() async {
    var response = await _tripAPIs.getAllMarker();
    if (response.success) {
      lstMarker = (response.data["markers"] as List)
          .map((item) => MarkerData.fromJson(item))
          .toList();
      lstAllMarker = (response.data["markers"] as List)
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

  Future<ApiResponse> deleteMarker(String markerId, String tripId) async {
    return await _tripAPIs.deleteMarker(markerId, tripId);
  }

  Future<ApiResponse> deleteWayPoints(LatLng latLang, String tripId) async {
    return await _tripAPIs.deleteWayPoints(latLang, tripId);
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

  Future<ApiResponseWithData> generateGpxUrl(String tripId) async {
    return await _tripAPIs.generateGpx(tripId);
  }

  Future<ApiResponse> updateProfile(String name, String number, String userUnit,
      String userWeatherPref) async {
    return await _tripAPIs.updateProfile(
        name, number, userUnit, userWeatherPref);
  }
}
