import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';

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
  static const String baseUrl = "http://44.196.64.110:5647/";
  static const int timeoutInSeconds = 20;
  static const String internalServerErrorMessage = "Internal server error.";

  Future<Map<String, String>> getHeaders() async {
    String accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  Future<ApiResponse> get(String urlSuffix,
      {Map<String, dynamic>? queryParams}) async {
    Uri uri =
        Uri.parse('$baseUrl$urlSuffix').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: await getHeaders()).timeout(
            Duration(seconds: timeoutInSeconds),
          );
      return _processResponse(response);
    } catch (e) {
      return ApiResponse("Request failed", false);
    }
  }

  Future<ApiResponseWithData<T>> getWithData<T>(String urlSuffix, T defaultData,
      {Map<String, dynamic>? queryParams}) async {
    Uri uri =
        Uri.parse('$baseUrl$urlSuffix').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: await getHeaders()).timeout(
            Duration(seconds: timeoutInSeconds),
          );
      return _processResponseWithData(response, defaultData);
    } catch (e) {
      return ApiResponseWithData(defaultData, false, message: "Request failed");
    }
  }

  Future<ApiResponse> post(String urlSuffix, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$urlSuffix'),
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );
      return _processResponse(response);
    } catch (e) {
      return ApiResponse("Request failed", false);
    }
  }

  Future<ApiResponseWithData<T>> postWithData<T>(
      String urlSuffix, Map<String, dynamic> body, T defaultData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$urlSuffix'),
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );
      return _processResponseWithData(response, defaultData);
    } catch (e) {
      return ApiResponseWithData(defaultData, false, message: "Request failed");
    }
  }

  Future<ApiResponse> delete(
      String urlSuffix, Map<String, dynamic> body) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$urlSuffix'),
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );
      return _processResponse(response);
    } catch (e) {
      return ApiResponse("Request failed", false);
    }
  }

  Future<ApiResponse> put(String urlSuffix, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$urlSuffix'),
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );
      return _processResponse(response);
    } catch (e) {
      return ApiResponse("Request failed", false);
    }
  }

  Future<ApiResponse> patch(String urlSuffix, Map<String, dynamic> body) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl$urlSuffix'),
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(
            Duration(seconds: timeoutInSeconds),
          );
      return _processResponse(response);
    } catch (e) {
      return ApiResponse("Request failed", false);
    }
  }

  ApiResponse _processResponse(http.Response response) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    String message = data["message"] ?? internalServerErrorMessage;
    if (kDebugMode) {
      // print('Response: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ApiResponse(data['message'] ?? internalServerErrorMessage, true);
    }
    return ApiResponse(message, false);
  }

  ApiResponseWithData<T> _processResponseWithData<T>(
      http.Response response, T defaultData) {
    if (kDebugMode) {
      //  print('Response: ${response.body}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    String message = data["message"] ?? internalServerErrorMessage;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiResponseWithData(data as T, true);
    }
    return ApiResponseWithData(defaultData, false, message: message);
  }
}
