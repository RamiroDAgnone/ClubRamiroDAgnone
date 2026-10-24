import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";
import "firebase_options.dart";
import "screens/login/login_screen.dart";
import "theme/app_theme.dart";
import "theme/theme_controller.dart";

Future<void> main() async {
  // Needed before any async work that happens before runApp.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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