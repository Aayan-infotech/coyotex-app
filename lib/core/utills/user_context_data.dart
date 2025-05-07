import 'package:coyotex/feature/auth/data/model/user_model.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/login_screen.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class UserContextData {
  static UserModel? _user;

  static UserModel? get user => _user;

  /// Fetch all necessary user-related data
  static Future<void> setCurrentUserAndFetchUserData(
      BuildContext context) async {
    try {
      final userProvider = Provider.of<UserViewModel>(context, listen: false);
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      final tripProvider = Provider.of<TripViewModel>(context, listen: false);

      List<Future> lstFutures = <Future>[
        userProvider.getUser(),
        tripProvider.getAllMarker(),
        // Uncomment if needed:
        // userProvider.getSubscriptionDetails(),
        // userProvider.getSubscriptionPlan(),
        // mapProvider.getCurrentLocation(),
        // mapProvider.getTrips(),
      ];

      await Future.wait(lstFutures);

      _user = userProvider.user;
    } catch (e) {
      debugPrint('User data fetch failed: $e');

      // Optional: Handle logout if needed
      if (e.toString().contains('Token expired') ||
          e.toString().contains('Unauthorized')) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
  
}
