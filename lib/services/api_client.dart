import "dart:async";
import "dart:convert";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "api_exceptions.dart";
import "auth_exceptions.dart";

// The Android emulator reaches the PC through 10.0.2.2, not 127.0.0.1.
String get apiBaseUrl {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return "http://10.0.2.2:8000";
  }
  return "http://127.0.0.1:8000";
}

// Single entry point to call the Python REST API.
// Adds the Firebase token to every request and translates the failures.
class ApiClient {
  static const _timeout = Duration(seconds: 10);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) {
    return _send(
      (uri, headers) => http.post(uri, headers: headers, body: jsonEncode(body)),
      path,
    );
  }
    Future<Map<String, dynamic>> get(String path) {
    return _send((uri, headers) => http.get(uri, headers: headers), path);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) {
    return _send(
      (uri, headers) => http.put(uri, headers: headers, body: jsonEncode(body)),
      path,
    );
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function(Uri uri, Map<String, String> headers) call,
    String path,
  ) async {
    // Always fresh: the SDK refreshes it if it is about to expire.
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    final http.Response response;
    try {
      response = await call(Uri.parse("$apiBaseUrl$path"), headers).timeout(_timeout);
    } on http.ClientException {
      // Could not reach the server (no internet, server down).
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException();
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    if (response.statusCode == 401) throw const ApiUnauthorizedException();
    if (response.statusCode == 409) throw const ApiConflictException();
    throw ApiServerException(response.statusCode);
  }
}