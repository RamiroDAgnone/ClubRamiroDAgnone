import "package:flutter/material.dart";
import "screens/login/login_screen.dart";
import "./screens/main_shell.dart";
import "theme/app_theme.dart";
import "theme/theme_controller.dart";

void main() {
  runApp(const ClubRamiroDAgnoneApp());
}

class ClubRamiroDAgnoneApp extends StatelessWidget {
  const ClubRamiroDAgnoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds the app every time themeModeNotifier changes.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: "Club Ramiro D'Agnone",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const LoginScreen(),
        );
      },
    );
  }
}