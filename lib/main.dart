import "package:flutter/material.dart";
import "screens/login/login_screen.dart";
import "./screens/main_shell.dart";

void main() {
  runApp(const ClubRamiroDagnoneApp());
}

class ClubRamiroDagnoneApp extends StatelessWidget {
  const ClubRamiroDagnoneApp({super.key});

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