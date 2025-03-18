import 'package:coyotex/core/services/api_base.dart';
import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/services/model/notification_model.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/model/pref_model.dart';

class LoginAPIs extends ApiBase {
  LoginAPIs() : super();

  Future<ApiResponseWithData<Map<String, dynamic>>> login(
      String email, String password) async {
    Map<String, String> data = {
      'email': email,
      'password': password,
    };

    return await CallHelper().postWithData('api/auth/login', data, {});
  }

  Future<ApiResponse> updateProfile(String name, String number, String userUnit,
      String userWeatherPref) async {
    Map<String, String> data = {
      "name": name,
      "number": number,
      "userUnit": userUnit,
      "userWeatherPref": userWeatherPref
    };

    return await CallHelper().patch(
      'api/update-details',
      data,
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getSubscription() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData(
      'api/subscriptions/active',
      data,
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> signUp(
      String name,
      String mobileNumber,
      String password,
      String referralCode,
      String email) async {
    Map<String, String> data = {
      "name": name,
      "number": mobileNumber,
      "email": email,
      "password": password,
      "confirmPassword": password,
      "referralCode": referralCode
    };
    return await CallHelper().postWithData('api/auth/signup', data, {});
  }

  //
  Future<ApiResponse> refresh(String refreshToken) async {
    Map<String, String> data = {
      'refreshToken': refreshToken,
    };
    return await CallHelper().post('api/auth/refresh-token', data);
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> verifyOTP(
      String email, String otp) async {
    Map<String, String> data = {
      'email': email,
      'otp': otp,
    };
    return await CallHelper().postWithData('api/auth/verify-otp', data, {});
  }

  Future<ApiResponse> resetPassword(
      String email, String otp, String newPassword) async {
    Map<String, String> data = {
      "email": email,
      "otp": otp,
      "newPassword": newPassword,
      "confirmPassword": newPassword
    };
    return await CallHelper().patch(
      'api/auth/reset-password',
      data,
    );
  }

  Future<ApiResponse> passwordReset(String token, String password) async {
    Map<String, String> data = {
      'newPassword': password,
      'token': token,
    };

    return await CallHelper().post('api/auth/reset-password', data);
  }

  Future<ApiResponse> updateUserFCM(
    String token,
  ) async {
    Map<String, String> data = {
      'fcmToken': token,
    };

    return await CallHelper().post('api/users/update-fcm', data);
  }

  Future<ApiResponse> sendUserNotification(
    String title,
    String body,
    NotificationType type,
    String tripId,
  ) async {
    String id = SharedPrefUtil.getValue(userIdPref, "") as String;

    Map<String, dynamic> data = {
      "userId": id,
      "title": title,
      "body": body,
      "type": type,
      "data": {"tripId": tripId}
    };

    return await CallHelper().post('api/notifications/send', data);
  }

  Future<ApiResponse> logout() async {
    String refToken = SharedPrefUtil.getValue(refreshTokenPref, "") as String;

    Map<String, String> data = {
      'refreshToken': refToken,
    };

    var res = await CallHelper().post(
      'api/auth/logout',
      data,
    );
    return res;
  }

  Future<ApiResponse> forgetPassword(String email) async {
    Map<String, String> data = {
      'email': email,
    };

    return await CallHelper().post('api/auth/forgot-password', data);
  }

  Future<ApiResponse> changePassword(
      String oldPassword, String newPassword, String confirmNewPassword) async {
    Map<String, String> data = {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
      "confirmNewPassword": confirmNewPassword,
    };
    return await CallHelper().patch(
      'api/auth/change-password',
      data,
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getNotifications() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData(
      'api/notifications',
      data,
    );
  }

  Future<ApiResponse> updatePref(UserPreferences prefrences) async {
    Map<String, String?> data = {
      'userPlan': prefrences.userPlan.isEmpty ? null : prefrences.userPlan,
      'userUnit': prefrences.userUnit.isEmpty ? null : prefrences.userUnit,
      'userWeatherPref': prefrences.userWeatherPref.isEmpty
          ? null
          : prefrences.userWeatherPref,
    };

    prefrences.toJson();
    return await CallHelper().patch(
      'api/update-preferences',
      data,
    );
  }

  Future<ApiResponseWithData> getUserById() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData('api/userById', data);
  }
}
