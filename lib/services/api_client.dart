import "dart:async";
import "dart:convert";
import "package:firebase_auth/firebase_auth.dart";
//import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "api_exceptions.dart";
import "auth_exceptions.dart";

// The Android emulator reaches the PC through 10.0.2.2, not 127.0.0.1.
/*String get apiBaseUrl {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return "http://10.0.2.2:8000";
  }
  return "http://127.0.0.1:8000";
}*/

// Production API hosted on Render.
const apiBaseUrl = "https://clubramirodagnone.onrender.com";

// Single entry point to call the Python REST API.
// Adds the Firebase token to every request and translates the failures.
class ApiClient {
  static const _timeout = Duration(seconds: 60);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final data = await _send(
      (uri, headers) => http.post(uri, headers: headers, body: jsonEncode(body)),
      path,
    );
    return data;
  }
  
  Future<Map<String, dynamic>> get(String path) async {
    final data = await _send((uri, headers) => http.get(uri, headers: headers), path);
    return data;
  }

  // For endpoints that answer with a JSON list (GET /venues...).
  Future<List<dynamic>> getList(String path) async {
    final data = await _send((uri, headers) => http.get(uri, headers: headers), path);
    return data as List<dynamic>;
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final data = await _send(
      (uri, headers) => http.put(uri, headers: headers, body: jsonEncode(body)),
      path,
    );
    return data;
  }

  Future<Map<String, dynamic>> patch(String path) async {
    final data = await _send(
      (uri, headers) => http.patch(uri, headers: headers),
      path,
    );
    return data as Map<String, dynamic>;
  }

  Future<dynamic> _send(
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
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    if (response.statusCode == 401) throw const ApiUnauthorizedException();
    if (response.statusCode == 409) throw const ApiConflictException();
    throw ApiServerException(response.statusCode);
  }
}