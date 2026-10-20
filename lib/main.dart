import "package:flutter/material.dart";
import "screens/login/login_screen.dart";
import "./screens/main_shell.dart";

void main() {
  runApp(const ClubRamiroDAgnoneApp());
}


class ClubRamiroDAgnoneApp extends StatelessWidget {
  const ClubRamiroDAgnoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Club Ramiro D'Agnone",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}