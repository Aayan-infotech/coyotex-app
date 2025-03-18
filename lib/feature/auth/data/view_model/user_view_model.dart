import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/services/model/notification_model.dart';
import 'package:coyotex/core/services/server_calls/auth_apis.dart';
import 'package:coyotex/core/services/server_calls/trip_apis.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/notification.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/core/utills/user_context_data.dart';
import 'package:coyotex/feature/auth/data/model/plans.dart';
import 'package:coyotex/feature/auth/data/model/pref_model.dart';
import 'package:coyotex/feature/auth/data/model/user_model.dart';
import 'package:coyotex/feature/homeScreen/screens/home_screen.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserViewModel extends ChangeNotifier {
  final LoginAPIs _loginAPIs = LoginAPIs();

  // Variables to store response states
  bool isLoading = false;
  String errorMessage = '';
  List<TripModel> trips = [];
  TripAPIs _tripAPIs = TripAPIs();

  Map<String, dynamic>? userData;
  List<Plan> lstPlan = [];
  UserModel user = UserModel(
      imageUrl: '',
      userId: '',
      name: '',
      number: '',
      email: '',
      isVerified: false,
      referralCode: '',
      userPlan: '',
      userUnit: 'KM',
      userWeatherPref: '',
      insIp: '',
      userStatus: 1,
      insDate: DateTime.now());

  // Login
  List<NotificationModel> lstNotification = [];

  Future<ApiResponseWithData> login(
      String email, String password, BuildContext context) async {
    final tripProvider = Provider.of<TripViewModel>(context, listen: false);
    _setLoading(true);
    try {
      final response = await _loginAPIs.login(email, password);
      if (response.success) {
        SharedPrefUtil.setValue(accessTokenPref, response.data["accessToken"]);
        SharedPrefUtil.setValue(
            refreshTokenPref, response.data["refreshToken"]);

        NotificationService.getDeviceToken();
        await UserContextData.setCurrentUserAndFetchUserData(context);

        // await getUser();
        // await tripProvider.getAllMarker();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );

        return response;
      } else {
        errorMessage = response.message;
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponseWithData(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> createPaymentIntent(
      String payment, String currency) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.createPaymentIntent(payment, currency);
      if (response.success) {
        return response;
      } else {
        errorMessage = response.message;
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponseWithData({"error": errorMessage}, false);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> paymentStatus(
      String paymentId) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.paymentStatus(paymentId);
      if (response.success) {
        return response;
      } else {
        errorMessage = response.message;
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponseWithData({"error": errorMessage}, false);
    } finally {
      _setLoading(false);
    }
  }

  getTrips() async {
    isLoading = true;
    notifyListeners();
    var response = await _tripAPIs.getUserTrip();
    if (response.success) {
      trips = (response.data["data"] as List).map((item) {
        return TripModel.fromJson(item);
      }).toList();
      print(trips);
    }
    notifyListeners();
    isLoading = false;
  }

  Future<ApiResponseWithData> getUser() async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.getUserById();
      if (response.success) {
        user = UserModel.fromJson(response.data);
        SharedPrefUtil.setValue(userIdPref, user.userId);

        return response;
      } else {
        errorMessage = response.message;
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponseWithData(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponseWithData> getNotifications() async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.getNotifications();
      if (response.success) {
        lstNotification = (response.data["data"] as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList();
        return response;
      } else {
        errorMessage = response.message;
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponseWithData(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  int animalKilled = 0;
  int animalSeen = 0;
  Future<ApiResponseWithData<Map<String, dynamic>>> getAnimalStats() async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.getAnimalStats();
      if (response.success) {
        // Handle successful response here
        animalKilled = response.data["totalAnimalKilled"];
        animalSeen = response.data["totalAnimalSeen"];

        print('Animal stats: ${response.data}');
        return response;
      } else {
        errorMessage = response.message;
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponseWithData({"error": errorMessage}, false);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponse> sendNotifications(
    String title,
    String body,
    NotificationType type,
    String tripId,
  ) async {
    _setLoading(true);
    try {
      final response =
          await _loginAPIs.sendUserNotification(title, body, type, tripId);
      if (response.success) {
        await getNotifications();
        return response;
      } else {
        errorMessage = response.message;
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponse(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponseWithData> getSubscriptionPlan() async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.getSubscription();
      if (response.success) {
        // Parse subscriptions as a list of Plan objects
        lstPlan = (response.data["subscriptions"] as List<dynamic>)
            .map((item) => Plan.fromJson(item))
            .toList();
        return response;
      } else {
        errorMessage = response.message;
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponseWithData(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  // Sign Up
  Future<ApiResponseWithData> signUp(String name, String mobileNumber,
      String password, String referralCode, String email) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.signUp(
          name, mobileNumber, password, referralCode, email);
      if (response.success) {
        return response;
      } else {
        errorMessage = response.message;
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponseWithData({}, false);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponse> updateUserProfile(
    String name,
    String mobileNumber,
    String userUnit,
    String weather,
  ) async {
    _setLoading(true);
    try {
      final response =
          await _loginAPIs.updateProfile(name, mobileNumber, userUnit, weather);
      if (response.success) {
        await getUser();
        return response;
      } else {
        errorMessage = response.message;
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponse(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponseWithData> verifyOTP(String email, String otp) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.verifyOTP(email, otp);
      return response;
    } catch (e) {
      errorMessage = e.toString();

      return ApiResponseWithData(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<ApiResponse> updatePref(UserPreferences userPreferences) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.updatePref(userPreferences);
      if (response.success) {
        await getUser();
      }
      return response;
    } catch (e) {
      errorMessage = e.toString();

      return ApiResponse(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponse> logout() async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.logout();
      return response;
    } catch (e) {
      errorMessage = e.toString();

      return ApiResponse(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  // Verify Token
  Future<ApiResponse> resetPassword(
      String email, String otp, String newPassword) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.resetPassword(email, otp, newPassword);
      if (response.success) {
        return response;
        // userData = response.data;
      } else {
        errorMessage = response.message;
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponse(e.toString(), false);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponse> forgotPassword(String email) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.forgetPassword(email);
      if (!response.success) {
        errorMessage = response.message;
        return response;
      } else {
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponse(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  // Password Reset
  Future<ApiResponse> changePassword(
      String oldPassword, String newPassword, String confirmNewPassword) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.changePassword(
          oldPassword, newPassword, confirmNewPassword);
      if (!response.success) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponse(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  // Helper to manage loading state
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // Clear error messages
  void clearErrorMessage() {
    errorMessage = '';
    notifyListeners();
  }
}
