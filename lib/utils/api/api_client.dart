import 'dart:async';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../providers/shared_preference_builder.dart';

/// Thin wrapper around package:http used by providers.
///
/// Adds three things every call needs:
///  - a request timeout, so a dead network fails instead of hanging forever
///  - the Authorization header from stored credentials
///  - centralized 401 handling: the token is cleared and [onUnauthorized]
///    fires (main.dart uses it to return the user to the login screen)
class ApiClient {
  /// Injectable for tests (e.g. package:http/testing.dart MockClient).
  static http.Client httpClient = http.Client();

  static Duration timeout = const Duration(seconds: 20);

  /// Called once whenever a request comes back 401 with a token present.
  static void Function()? onUnauthorized;

  static Map<String, String> _headers({bool auth = true}) {
    final headers = <String, String>{};
    if (auth) {
      final token = SharedPrefrenceBuilder.getUserToken;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static http.Response _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401 &&
        SharedPrefrenceBuilder.getUserToken != null) {
      log('401 received, clearing session', name: 'ApiClient');
      SharedPrefrenceBuilder.clearInvalidToken();
      onUnauthorized?.call();
    }
    return response;
  }

  static Future<http.Response> get(String url, {bool auth = true}) async {
    final response = await httpClient
        .get(Uri.parse(url), headers: _headers(auth: auth))
        .timeout(timeout);
    return _checkUnauthorized(response);
  }

  static Future<http.Response> post(
    String url, {
    Map<String, String>? body,
    bool auth = true,
  }) async {
    final response = await httpClient
        .post(Uri.parse(url), headers: _headers(auth: auth), body: body)
        .timeout(timeout);
    return _checkUnauthorized(response);
  }
}

/// Drop-in replacement for http.get/http.post at call sites that build their
/// own headers, adding the timeout and 401 handling from [ApiClient].
class SafeHttp {
  static Future<http.Response> get(Uri url,
      {Map<String, String>? headers}) async {
    final response = await ApiClient.httpClient
        .get(url, headers: headers)
        .timeout(ApiClient.timeout);
    return ApiClient._checkUnauthorized(response);
  }

  static Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body}) async {
    final response = await ApiClient.httpClient
        .post(url, headers: headers, body: body)
        .timeout(ApiClient.timeout);
    return ApiClient._checkUnauthorized(response);
  }
}
