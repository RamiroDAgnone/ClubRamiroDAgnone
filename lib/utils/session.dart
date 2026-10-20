import "package:flutter/material.dart";
import "../screens/login/login_screen.dart";

// Temporary: later this will also sign out from Firebase and clear the stored session.
void logout(BuildContext context) {
  // Grab the messenger BEFORE navigating: it lives above the Navigator,
  // so the message survives the change of screen.
  final messenger = ScaffoldMessenger.of(context);

  // Removes ALL previous screens, so the back button cannot return to the app.
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );

  messenger.showSnackBar(
    const SnackBar(content: Text("Sesión cerrada exitosamente")),
  );
}