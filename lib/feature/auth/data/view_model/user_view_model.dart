import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/services/server_calls/auth_apis.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:flutter/material.dart';

class UserViewModel extends ChangeNotifier {
  final LoginAPIs _loginAPIs = LoginAPIs();

  // Variables to store response states
  bool isLoading = false;
  String errorMessage = '';
  Map<String, dynamic>? userData;

  // Login
  Future<ApiResponseWithData> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.login(email, password);
      if (response.success) {
        SharedPrefUtil.setValue(accessTokenPref, response.data["accessToken"]);
        SharedPrefUtil.setValue(
            refreshTokenPref, response.data["refreshToken"]);
        userData = response.data;
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
  Future<ApiResponseWithData> signUp(String userName, String password,
      String referralCode, String email) async {
    _setLoading(true);
    try {
      final response =
          await _loginAPIs.signUp(userName, password, referralCode, email);
      if (response.success) {
        userData = response.data;
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

  // Send OTP
  Future<void> sendOTP(String email) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.refreshToken(email);
      if (!response.success) {
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
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

  // Verify Token
  Future<void> verifyToken(String token) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.verifyToken(token);
      if (response.success) {
        userData = response.data;
      } else {
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Check User Existence
  Future<void> checkUserExistence(String mobile) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.checkUserExistence(mobile);
      if (!response.success) {
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Password Reset
  Future<void> passwordReset(String token, String password) async {
    _setLoading(true);
    try {
      final response = await _loginAPIs.passwordReset(token, password);
      if (!response.success) {
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = e.toString();
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
