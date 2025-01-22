import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:exponential_back_off/exponential_back_off.dart';

class ApiResponse {
  final String message;
  final bool success;

  ApiResponse(this.message, this.success);
}

class ApiResponseWithData<T> {
  final T data;
  final bool success;
  final String message;

  ApiResponseWithData(this.data, this.success, {this.message = "none"});
}

class CallHelper {
  static final Dio dio = Dio();

  final exponentialBackOff = ExponentialBackOff(
    interval:
        const Duration(milliseconds: 2000), // Retry after 2, 4, 8, 16 seconds
    maxAttempts: 5,
    maxRandomizationFactor: 0.0,
    maxDelay: const Duration(seconds: 30),
  );

  static String url = "http://44.196.64.110:5647/";
  int timeoutInSeconds = 20;
  String internalServerErrorMessage = "Internal server error.";

  Future<Map<String, String>> getHeaders() async {
    String accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    const String role = '';
    const String id = '';

    var headers = {
      'role': role.toUpperCase(),
      'id': id,
      'Authorization': 'Bearer $accessToken', // Uncomment if needed
      'Content-Type': 'application/json',
    };
    return headers;
  }

  Future<ApiResponse> get(String urlSuffix,
      {Map<String, dynamic>? queryParams}) async {
    Uri uri = Uri.parse('$url$urlSuffix').replace(queryParameters: queryParams);

    try {
      final response = await dio
          .getUri(uri, options: Options(headers: await getHeaders()))
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );

      if (kDebugMode) {
        print('Response: ${response.data}');
      }

      if (response.statusCode == 200) {
        String message = response.data['Message'] ?? internalServerErrorMessage;
        return ApiResponse(message, true);
      } else {
        return ApiResponse(internalServerErrorMessage, false);
      }
    } on DioError catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponseWithData<T>> getWithData<T>(String urlSuffix, T defaultData,
      {Map<String, dynamic>? queryParams}) async {
    Uri uri = Uri.parse('$url$urlSuffix').replace(queryParameters: queryParams);

    try {
      final response = await dio
          .getUri(uri, options: Options(headers: await getHeaders()))
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );

      if (kDebugMode) {
        print('Response: ${response.data}');
      }

      if (response.statusCode == 200) {
        return ApiResponseWithData(response.data as T, true);
      } else if (response.statusCode == 404) {
        return ApiResponseWithData(defaultData, false, message: "Not Found");
      } else {
        return ApiResponseWithData(
          defaultData,
          false,
          message: response.data['message'] ?? internalServerErrorMessage,
        );
      }
    } on DioError catch (e) {
      return ApiResponseWithData(defaultData, false, message: '');
    }
  }

  Future<ApiResponse> post(String urlSuffix, Map<String, dynamic> body) async {
    try {
      final response = await dio
          .post('$url$urlSuffix',
              data: jsonEncode(body),
              options: Options(headers: await getHeaders()))
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );

      if (response.statusCode == 200) {
        return ApiResponse(
            response.data['Message'] ?? internalServerErrorMessage, true);
      } else {
        return ApiResponse(internalServerErrorMessage, false);
      }
    } on DioError catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponseWithData<T>> postWithData<T>(
      String urlSuffix, Map<String, dynamic> body, T defaultData) async {
    try {
      final response = await dio
          .post('$url$urlSuffix',
              data: jsonEncode(body),
              options: Options(headers: await getHeaders()))
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponseWithData(response.data as T, true);
      } else {
        return ApiResponseWithData(defaultData, false,
            message: response.data['message'] ?? internalServerErrorMessage);
      }
    } on DioError catch (e) {
      print(e);
      return ApiResponseWithData(defaultData, false, message: e.toString());
    }
  }

  Future<ApiResponse> delete(
      String urlSuffix, Map<String, dynamic> body) async {
    try {
      final response = await dio
          .delete('$url$urlSuffix',
              data: jsonEncode(body),
              options: Options(headers: await getHeaders()))
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );

      if (response.statusCode == 200) {
        return ApiResponse(
            response.data['Message'] ?? internalServerErrorMessage, true);
      } else {
        return ApiResponse(internalServerErrorMessage, false);
      }
    } on DioError catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse> put(String urlSuffix, Map<String, dynamic> body) async {
    try {
      final response = await dio
          .put('$url$urlSuffix',
              data: jsonEncode(body),
              options: Options(headers: await getHeaders()))
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );

      if (response.statusCode == 200) {
        return ApiResponse(
            response.data['Message'] ?? internalServerErrorMessage, true);
      } else {
        return ApiResponse(internalServerErrorMessage, false);
      }
    } on DioError catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse> patch(String urlSuffix, Map<String, dynamic> body) async {
    try {
      final response = await dio
          .patch('$url$urlSuffix',
              data: jsonEncode(body),
              options: Options(headers: await getHeaders()))
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );

      if (response.statusCode == 200) {
        return ApiResponse(
            response.data['Message'] ?? internalServerErrorMessage, true);
      } else {
        return ApiResponse(internalServerErrorMessage, false);
      }
    } on DioError catch (e) {
      return _handleDioError(e);
    }
  }

  ApiResponse _handleDioError(DioError error) {
    if (error.type == DioErrorType.cancel ||
        error.type == DioErrorType.receiveTimeout) {
      return ApiResponse("Request timed out", false);
    } else if (error.response != null) {
      return ApiResponse(
          error.response?.data['Message'] ?? internalServerErrorMessage, false);
    } else {
      return ApiResponse(error.response?.data['Message'], false);
    }
  }
}
