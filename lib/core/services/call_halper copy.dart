import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';

// class ApiResponse {
//   final String message;
//   final bool success;

//   ApiResponse(this.message, this.success);
// }

// class ApiResponseWithData<T> {
//   final T data;
//   final bool success;
//   final String message;

//   ApiResponseWithData(this.data, this.success, {this.message = "none"});
// }

// class CallHelper {
//   static const String baseUrl = "http://44.196.64.110:5647/";
//   static const int timeoutInSeconds = 20;
//   static const String internalServerErrorMessage = "Internal server error.";

//   Future<Map<String, String>> getHeaders() async {
//     String accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
//     return {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     };
//   }

//   Future<ApiResponse> get(String urlSuffix,
//       {Map<String, dynamic>? queryParams}) async {
//     Uri uri =
//         Uri.parse('$baseUrl$urlSuffix').replace(queryParameters: queryParams);

//     try {
//       final response = await http.get(uri, headers: await getHeaders()).timeout(
//             Duration(seconds: timeoutInSeconds),
//           );
//       return _processResponse(response);
//     } catch (e) {
//       return ApiResponse("Request failed", false);
//     }
//   }

//   Future<ApiResponseWithData<T>> getWithData<T>(String urlSuffix, T defaultData,
//       {Map<String, dynamic>? queryParams}) async {
//     Uri uri =
//         Uri.parse('$baseUrl$urlSuffix').replace(queryParameters: queryParams);

//     try {
//       final response = await http.get(uri, headers: await getHeaders()).timeout(
//             Duration(seconds: timeoutInSeconds),
//           );
//       return _processResponseWithData(response, defaultData);
//     } catch (e) {
//       return ApiResponseWithData(defaultData, false, message: "Request failed");
//     }
//   }

//   Future<ApiResponse> post(String urlSuffix, Map<String, dynamic> body) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$baseUrl$urlSuffix'),
//             headers: await getHeaders(),
//             body: jsonEncode(body),
//           )
//           .timeout(
//             Duration(seconds: timeoutInSeconds),
//           );
//       return _processResponse(response);
//     } catch (e) {
//       return ApiResponse("Request failed", false);
//     }
//   }

//   Future<ApiResponseWithData<T>> postWithData<T>(
//       String urlSuffix, Map<String, dynamic> body, T defaultData) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$baseUrl$urlSuffix'),
//             headers: await getHeaders(),
//             body: jsonEncode(body),
//           )
//           .timeout(
//             Duration(seconds: timeoutInSeconds),
//           );
//       return _processResponseWithData(response, defaultData);
//     } catch (e) {
//       return ApiResponseWithData(defaultData, false, message: "Request failed");
//     }
//   }

//   Future<ApiResponse> delete(
//       String urlSuffix, Map<String, dynamic> body) async {
//     try {
//       final response = await http
//           .delete(
//             Uri.parse('$baseUrl$urlSuffix'),
//             headers: await getHeaders(),
//             body: jsonEncode(body),
//           )
//           .timeout(
//             Duration(seconds: timeoutInSeconds),
//           );
//       return _processResponse(response);
//     } catch (e) {
//       return ApiResponse("Request failed", false);
//     }
//   }

//   Future<ApiResponse> put(String urlSuffix, Map<String, dynamic> body) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$baseUrl$urlSuffix'),
//             headers: await getHeaders(),
//             body: jsonEncode(body),
//           )
//           .timeout(
//             Duration(seconds: timeoutInSeconds),
//           );
//       return _processResponse(response);
//     } catch (e) {
//       return ApiResponse("Request failed", false);
//     }
//   }

//   Future<ApiResponse> patch(String urlSuffix, Map<String, dynamic> body) async {
//     try {
//       final response = await http
//           .patch(
//             Uri.parse('$baseUrl$urlSuffix'),
//             headers: await getHeaders(),
//             body: jsonEncode(body),
//           )
//           .timeout(
//             Duration(seconds: timeoutInSeconds),
//           );
//       return _processResponse(response);
//     } catch (e) {
//       return ApiResponse("Request failed", false);
//     }
//   }

//   ApiResponse _processResponse(http.Response response) {
//     final Map<String, dynamic> data = jsonDecode(response.body);
//     String message = data["message"] ?? internalServerErrorMessage;
//     if (kDebugMode) {
//       // print('Response: ${response.body}');
//     }

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final Map<String, dynamic> data = jsonDecode(response.body);
//       return ApiResponse(data['message'] ?? internalServerErrorMessage, true);
//     }
//     return ApiResponse(message, false);
//   }

//   ApiResponseWithData<T> _processResponseWithData<T>(
//       http.Response response, T defaultData) {
//     if (kDebugMode) {
//       //  print('Response: ${response.body}');
//     }

//     final Map<String, dynamic> data = jsonDecode(response.body);
//     String message = data["message"] ?? internalServerErrorMessage;
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return ApiResponseWithData(data as T, true);
//     }
//     return ApiResponseWithData(defaultData, false, message: message);
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:coyotex/core/utills/constant.dart';
// import 'package:coyotex/core/utills/shared_pref.dart';

// class ApiResponse {
//   final String message;
//   final bool success;

//   ApiResponse(this.message, this.success);
// }

// class ApiResponseWithData<T> {
//   final T data;
//   final bool success;
//   final String message;

//   ApiResponseWithData(this.data, this.success, {this.message = "none"});
// }

// class CallHelper {
//   static const String baseUrl = "http://44.196.64.110:5647/";
//   static const int timeoutInSeconds = 20;
//   static const String internalServerErrorMessage = "Internal server error.";
//   static bool _isRefreshing = false;
//   static Completer<void>? _refreshCompleter;

//   Future<Map<String, String>> getHeaders() async {
//     String accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
//     return {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     };
//   }

//   Future<ApiResponse> get(String urlSuffix,
//       {Map<String, dynamic>? queryParams}) async {
//     return _performRequest(() async {
//       Uri uri =
//           Uri.parse('$baseUrl$urlSuffix').replace(queryParameters: queryParams);
//       final response = await http
//           .get(uri, headers: await getHeaders())
//           .timeout(Duration(seconds: timeoutInSeconds));
//       return _processResponse(
//           response, () => get(urlSuffix, queryParams: queryParams));
//     });
//   }

//   Future<ApiResponseWithData<T>> getWithData<T>(String urlSuffix, T defaultData,
//       {Map<String, dynamic>? queryParams}) async {
//     return _performRequest(() async {
//       Uri uri =
//           Uri.parse('$baseUrl$urlSuffix').replace(queryParameters: queryParams);
//       final response = await http
//           .get(uri, headers: await getHeaders())
//           .timeout(Duration(seconds: timeoutInSeconds));
//       return _processResponseWithData(response, defaultData,
//           () => getWithData(urlSuffix, defaultData, queryParams: queryParams));
//     });
//   }

//   Future<ApiResponse> post(String urlSuffix, Map<String, dynamic> body) async {
//     return _performRequest(() async {
//       final response = await http
//           .post(
//             Uri.parse('$baseUrl$urlSuffix'),
//             headers: await getHeaders(),
//             body: jsonEncode(body),
//           )
//           .timeout(Duration(seconds: timeoutInSeconds));
//       return _processResponse(response, () => post(urlSuffix, body));
//     });
//   }

//   Future<ApiResponseWithData<T>> postWithData<T>(
//       String urlSuffix, Map<String, dynamic> body, T defaultData) async {
//     return _performRequest(() async {
//       final response = await http
//           .post(
//             Uri.parse('$baseUrl$urlSuffix'),
//             headers: await getHeaders(),
//             body: jsonEncode(body),
//           )
//           .timeout(Duration(seconds: timeoutInSeconds));
//       return _processResponseWithData(response, defaultData,
//           () => postWithData(urlSuffix, body, defaultData));
//     });
//   }

//   Future<ApiResponse> patch<T>(
//     String urlSuffix,
//     Map<String, dynamic> body,
//   ) async {
//     return _performRequest(() async {
//       final response = await http
//           .patch(
//             Uri.parse('$baseUrl$urlSuffix'),
//             headers: await getHeaders(),
//             body: jsonEncode(body),
//           )
//           .timeout(Duration(seconds: timeoutInSeconds));
//       return _processResponse(
//           response,
//           () => patch(
//                 urlSuffix,
//                 body,
//               ));
//     });
//   }

//   /// Handles API responses and retries if unauthorized (401).
//   ApiResponse _processResponse(
//       http.Response response, Future<ApiResponse> Function() retryRequest) {
//     if (response.statusCode == 401) {
//       return _handleUnauthorizedRequest(retryRequest);
//     }

//     final Map<String, dynamic> data = jsonDecode(response.body);
//     String message = data["message"] ?? internalServerErrorMessage;

//     return response.statusCode == 200 || response.statusCode == 201
//         ? ApiResponse(data['message'] ?? internalServerErrorMessage, true)
//         : ApiResponse(message, false);
//   }

//   ApiResponseWithData<T> _processResponseWithData<T>(http.Response response,
//       T defaultData, Future<ApiResponseWithData<T>> Function() retryRequest) {
//     if (response.statusCode == 401) {
//       return _handleUnauthorizedRequestWithData(defaultData, retryRequest);
//     }

//     final Map<String, dynamic> data = jsonDecode(response.body);
//     String message = data["message"] ?? internalServerErrorMessage;

//     return response.statusCode == 200 || response.statusCode == 201
//         ? ApiResponseWithData(data as T, true)
//         : ApiResponseWithData(defaultData, false, message: message);
//   }

//   /// Handles token refresh and retries the failed request.
//   _handleUnauthorizedRequest(Future<ApiResponse> Function() retryRequest) {
//     return _refreshToken().then((success) async {
//       if (success) return await retryRequest();
//       return ApiResponse("Session expired. Please log in again.", false);
//     }).catchError((_) => ApiResponse("Token refresh failed", false));
//   }

//   _handleUnauthorizedRequestWithData<T>(
//       T defaultData, Future<ApiResponseWithData<T>> Function() retryRequest) {
//     return _refreshToken().then((success) async {
//       if (success) return await retryRequest();
//       return ApiResponseWithData(defaultData, false,
//           message: "Session expired. Please log in again.");
//     }).catchError((_) => ApiResponseWithData(defaultData, false,
//         message: "Token refresh failed"));
//   }

//   /// Refreshes the token and updates stored credentials.
//   Future<bool> _refreshToken() async {
//     if (_isRefreshing) {
//       await _refreshCompleter?.future;
//       return SharedPrefUtil.getValue(accessTokenPref, "") != null;
//     }

//     _isRefreshing = true;
//     _refreshCompleter = Completer<void>();

//     try {
//       String refreshToken =
//           SharedPrefUtil.getValue(refreshTokenPref, "") as String;
//       final response = await http.post(
//         Uri.parse("${baseUrl}auth/refresh"),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({"refreshToken": refreshToken}),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         String newAccessToken = data["accessToken"] ?? "";
//         await SharedPrefUtil.setValue(accessTokenPref, newAccessToken);
//         _refreshCompleter?.complete();
//         _isRefreshing = false;
//         return true;
//       }
//     } catch (_) {}

//     _refreshCompleter?.complete();
//     _isRefreshing = false;
//     return false;
//   }

//   /// Wraps API calls with exception handling and retry logic.
//   Future<T> _performRequest<T>(Future<T> Function() requestFunction) async {
//     try {
//       return await requestFunction();
//     } catch (e) {
//       return Future.value(ApiResponse("Request failed", false) as T);
//     }
//   }
// }
