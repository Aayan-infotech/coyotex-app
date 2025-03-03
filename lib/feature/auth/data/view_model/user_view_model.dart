import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/services/server_calls/auth_apis.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/notification.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/model/plans.dart';
import 'package:coyotex/feature/auth/data/model/pref_model.dart';
import 'package:coyotex/feature/auth/data/model/user_model.dart';
import 'package:coyotex/feature/homeScreen/screens/home_screen.dart';
import 'package:flutter/material.dart';

class UserViewModel extends ChangeNotifier {
  final LoginAPIs _loginAPIs = LoginAPIs();

  // Variables to store response states
  bool isLoading = false;
  String errorMessage = '';
  Map<String, dynamic>? userData;
  List<Plan> lstPlan = [];
  UserModel user = UserModel(
    userId: '',
      name: '',
      number: '',
      email: '',
      isVerified: false,
      referralCode: '',
      userPlan: '',
      userUnit: '',
      userWeatherPref: '',
      insIp: '',
      userStatus: 1,
      insDate: DateTime.now());

  // Login
  Future<ApiResponseWithData> login(
      String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.login(email, password);
      if (response.success) {
        SharedPrefUtil.setValue(accessTokenPref, response.data["accessToken"]);
        SharedPrefUtil.setValue(
            refreshTokenPref, response.data["refreshToken"]);

        NotificationService.getDeviceToken();
        await getUser();

        // Navigator.of(context).push(
        //   MaterialPageRoute(builder: (context) {
        //     return HomeScreen();
        //   }),
        // );
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

  Future<ApiResponseWithData> getUser() async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.getUserById();
      if (response.success) {
        user = UserModel.fromJson(response.data);
        SharedPrefUtil.setValue(userIdPref, user.userId);
        print(user);
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
