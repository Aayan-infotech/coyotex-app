import 'package:coyotex/core/services/api_base.dart';
import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/utills/shared_pref.dart';

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

  Future<ApiResponseWithData<Map<String, dynamic>>> signUp(String userName,
      String password, String referralCode, String email) async {
    Map<String, String> data = {
      "email": email,
      "password": password,
      "confirmPassword": password,
      "referralCode": referralCode
    };

    return await CallHelper().postWithData('api/auth/signup', data, {});
  }

  //
  Future<ApiResponse> refreshToken(String refreshToken) async {
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
    return await CallHelper().postWithData('api/auth/verifyOTP', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> verifyToken(
      String token) async {
    Map<String, String> data = {
      'token': token,
    };
    return await CallHelper().postWithData('/api/auth/google', data, {});
  }

  Future<ApiResponse> checkUserExistence(String mobile) async {
    return await CallHelper().get('business/$mobile/existence/$mobile');
  }

  Future<ApiResponse> passwordReset(String token, String password) async {
    Map<String, String> data = {
      'newPassword': password,
      'token': token,
    };

    return await CallHelper().post('api/auth/reset-password', data);
  }
}
