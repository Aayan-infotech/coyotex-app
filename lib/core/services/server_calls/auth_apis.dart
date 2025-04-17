import 'package:coyotex/core/services/api_base.dart';
import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/services/model/notification_model.dart';
import 'package:coyotex/core/services/model/weather_model.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/model/pref_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LoginAPIs extends ApiBase {
  LoginAPIs() : super();

  Future<ApiResponseWithData<Map<String, dynamic>>> login(
      String email, String password) async {
    Map<String, String> data = {
      'email': email,
      'password': password,
    };

    return await CallHelper().postWithData('auth/login', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> dayStatus(
      LatLng latlang, WeatherResponse weather) async {
    Map<String, dynamic> data = {
      "latitude": latlang.latitude,
      "longitude": latlang.longitude,
      "windDirection": weather.wind.deg.toString(),
      "temperature": weather.main.temp,
      "humidity": weather.main.humidity,
      "pressure": weather.main.pressure
    };

    return await CallHelper()
        .postWithData('trips/animal-activity-prediction', data, {});
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
      'update-details',
      data,
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getSubscription() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData(
      'subscriptions/active',
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
    return await CallHelper().postWithData('auth/signup', data, {});
  }

  //
  Future<ApiResponse> refresh(String refreshToken) async {
    Map<String, String> data = {
      'refreshToken': refreshToken,
    };
    return await CallHelper().post('auth/refresh-token', data);
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> verifyOTP(
      String email, String otp) async {
    Map<String, String> data = {
      'email': email,
      'otp': otp,
    };
    return await CallHelper().postWithData('auth/verify-otp', data, {});
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
      'auth/reset-password',
      data,
    );
  }

  Future<ApiResponse> passwordReset(String token, String password) async {
    Map<String, String> data = {
      'newPassword': password,
      'token': token,
    };

    return await CallHelper().post('auth/reset-password', data);
  }

  Future<ApiResponse> updateUserFCM(
    String token,
  ) async {
    Map<String, String> data = {
      'fcmToken': token,
    };

    return await CallHelper().post('users/update-fcm', data);
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
      "type": type.toJson(),
      "data": {"tripId": tripId}
    };
//     {
//   "userId": "678e0135dfecdd53c910a47e",
//   "title": "Trip Update",
//   "body": "You have reached your next stop again!",
//   "type": "trip_update",
//   "data": { "tripId": "67c9aa76c6722545f5604965" }
// }
    print(data);

    return await CallHelper().post('notifications/send', data);
  }

  Future<ApiResponse> logout() async {
    String refToken = SharedPrefUtil.getValue(refreshTokenPref, "") as String;

    Map<String, String> data = {
      'refreshToken': refToken,
    };

    var res = await CallHelper().post(
      'auth/logout',
      data,
    );
    return res;
  }

  Future<ApiResponse> forgetPassword(String email) async {
    Map<String, String> data = {
      'email': email,
    };

    return await CallHelper().post('auth/forgot-password', data);
  }

  Future<ApiResponse> changePassword(
      String oldPassword, String newPassword, String confirmNewPassword) async {
    Map<String, String> data = {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
      "confirmNewPassword": confirmNewPassword,
    };
    return await CallHelper().patch(
      'auth/change-password',
      data,
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getNotifications() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData(
      'notifications',
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
      'update-preferences',
      data,
    );
  }

  Future<ApiResponseWithData> getUserById() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData('userById', data);
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> createPaymentIntent(
      String amount, String currency) async {
    Map<String, String> data = {
      "amount": amount,
      "currency": currency,
    };

    return await CallHelper().postWithData(
      'stripe/create-payment-intent',
      data,
      {},
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> paymentStatus(
    String paymentId,
  ) async {
    Map<String, String> data = {"paymentId": paymentId};

    return await CallHelper().postWithData(
      'stripe/payment-success',
      data,
      {},
    );
  }

  // New API call for animal stats
  Future<ApiResponseWithData<Map<String, dynamic>>> getAnimalStats() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData(
      'trips/trip/animal-stats',
      data,
    );
  }
  Future<ApiResponseWithData<Map<String, dynamic>>> getSubscriptionDetails() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData(
      'users/user-subscription',
      data,
    );
  }
}
