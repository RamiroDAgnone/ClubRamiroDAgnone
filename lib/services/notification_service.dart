import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "api_client.dart";

// Single entry point for push notifications (Firebase Cloud Messaging).
class NotificationService {
  final _api = ApiClient();

  Future<void> registerDevice() async {
    // Web needs extra setup (VAPID key + service worker): Android only for now.
    if (kIsWeb) return;

    final messaging = FirebaseMessaging.instance;
    
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken();
    debugPrint("FCM token: $token");
    if (token == null) return;
    await _sendToken(token);

    // FCM can rotate the token: keep the backend up to date.
    messaging.onTokenRefresh.listen(_sendToken);
  }

  Future<void> _sendToken(String token) async {
    try {
      await _api.post("/users/me/device-token", {
        "token": token,
        "platform": "android",
      });
    } catch (e) {
      // Notifications are a bonus: never break the app because of them.
      debugPrint("Could not register device token: $e");
    }
  }
}