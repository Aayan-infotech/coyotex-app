import 'dart:async';
import 'dart:convert';

import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

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
  static const String baseUrl =
      "https://www.thecoyotex.com/api/"; //"http://18.209.91.97:5648/api/";
  static const int timeoutInSeconds = 20;
  static const String internalServerErrorMessage = "Internal server error.";
  static bool _isRefreshing = false;
  static Completer<void>? _refreshCompleter;
  static void Function()? onLogout;

  late final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: timeoutInSeconds),
    responseType: ResponseType.json,
  ));

  CallHelper() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers = await _getHeaders();
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          if (_isRefreshing) {
            await _refreshCompleter?.future;
            return handler.next(error);
          }

          _isRefreshing = true;
          _refreshCompleter = Completer<void>();

          try {
            if (await _refreshToken()) {
              final opts = Options(
                method: error.requestOptions.method,
                headers: await _getHeaders(),
              );
              final response = await dio.request(
                _buildUrl(error.requestOptions.path),
                options: opts,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              _isRefreshing = false;
              _refreshCompleter?.complete();
              return handler.resolve(response);
            }
          } catch (e) {
            _isRefreshing = false;
            _refreshCompleter?.complete();
            if (onLogout != null) onLogout!();
            return handler.reject(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, String>> _getHeaders() async {
    String accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  String _buildUrl(String suffix) {
    if (suffix.startsWith("http")) return suffix;
    return "${dio.options.baseUrl}${suffix.startsWith("/") ? suffix.substring(1) : suffix}";
  }

  Future<ApiResponse> get(String urlSuffix,
      {Map<String, dynamic>? queryParams}) async {
    return _performRequest(() async {
      final response = await dio.get(
        _buildUrl(urlSuffix),
        queryParameters: queryParams,
      );
      return _processResponse(response);
    });
  }

  Future<ApiResponseWithData<T>> getWithData<T>(String urlSuffix, T defaultData,
      {Map<String, dynamic>? queryParams}) async {
    return _performRequest(() async {
      debugPrint("URL => ${_buildUrl(urlSuffix)}");
      final response = await dio.get(
        _buildUrl(urlSuffix),
        queryParameters: queryParams,
      );
      return _processResponseWithData(response, defaultData);
    });
  }

  Future<ApiResponse> delete(String urlSuffix,
      {Map<String, dynamic>? queryParams}) async {
    return _performRequest(() async {
      final response = await dio.delete(
        _buildUrl(urlSuffix),
        queryParameters: queryParams,
      );
      return _processResponse(response);
    });
  }

  Future<ApiResponse> post(String urlSuffix, Map<String, dynamic> body) async {
    return _performRequest(() async {
      final response = await dio.post(
        _buildUrl(urlSuffix),
        data: jsonEncode(body),
      );
      return _processResponse(response);
    });
  }

  Future<ApiResponseWithData<T>> postWithData<T>(
      String urlSuffix, Map<String, dynamic> body, T defaultData) async {
    return _performRequest(() async {
      final response = await dio.post(
        _buildUrl(urlSuffix),
        data: jsonEncode(body),
      );
      return _processResponseWithData(response, defaultData);
    });
  }

  Future<ApiResponseWithData<T>> putWithData<T>(
      String urlSuffix, Map<String, dynamic> body, T defaultData) async {
    return _performRequest(() async {
      debugPrint("URL => ${_buildUrl(urlSuffix)}");
      final response = await dio.put(
        _buildUrl(urlSuffix),
        data: jsonEncode(body),
      );
      return _processResponseWithData(response, defaultData);
    });
  }

  Future<ApiResponse> deleteWithBody(
      String urlSuffix, Map<String, dynamic> body) async {
    return _performRequest(() async {
      final response = await dio.delete(
        _buildUrl(urlSuffix),
        data: jsonEncode(body),
      );
      return _processResponse(response);
    });
  }

  Future<ApiResponse> patch<T>(
      String urlSuffix, Map<String, dynamic> body) async {
    return _performRequest(() async {
      final response = await dio.patch(
        _buildUrl(urlSuffix),
        data: jsonEncode(body),
      );
      return _processResponse(response);
    });
  }

  ApiResponse _processResponse(Response response) {
    final data = response.data;
    String message = data["message"] ?? internalServerErrorMessage;

    return response.statusCode == 200 || response.statusCode == 201
        ? ApiResponse(data['message'] ?? internalServerErrorMessage, true)
        : ApiResponse(message, false);
  }

  ApiResponseWithData<T> _processResponseWithData<T>(
      Response response, T defaultData) {
    final data = response.data;
    String message = data["message"] ?? internalServerErrorMessage;

    return response.statusCode == 200 || response.statusCode == 201
        ? ApiResponseWithData(data as T, true)
        : ApiResponseWithData(defaultData, false, message: message);
  }

  Future<bool> _refreshToken() async {
    try {
      String refreshToken =
          SharedPrefUtil.getValue(refreshTokenPref, "") as String;
      final response = await dio.post(
        _buildUrl("auth/refresh-token"),
        data: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String newAccessToken = data["accessToken"] ?? "";
        await SharedPrefUtil.setValue(accessTokenPref, newAccessToken);
        return true;
      }
    } catch (_) {
      if (onLogout != null) onLogout!();
    }
    return false;
  }

  Future<T> _performRequest<T>(Future<T> Function() requestFunction) async {
    try {
      return await requestFunction();
    } on DioException catch (e) {
      debugPrint("API Error: ${e.message}");
      if (T == ApiResponseWithData<Map<String, dynamic>>) {
        return ApiResponseWithData<Map<String, dynamic>>({}, false,
            message: "Request failed") as T;
      } else if (T == ApiResponseWithData<String>) {
        return ApiResponseWithData<String>("Request failed", false,
            message: "Request failed") as T;
      } else if (T == ApiResponse) {
        return ApiResponse("Request failed", false) as T;
      } else {
        throw Exception("Unexpected return type in _performRequest: $T");
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return ApiResponse("Unexpected error occurred", false) as T;
    }
  }
}
