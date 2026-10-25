import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "firebase_options.dart";
import "screens/login/login_screen.dart";
import "screens/main_shell.dart";
import "theme/app_theme.dart";
import "theme/theme_controller.dart";

Future<void> main() async {
  // Needed before any async work that happens before runApp.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Waits until Firebase restores the saved session (on web it is async,
  // so reading currentUser directly could still return null).
  final user = await FirebaseAuth.instance.authStateChanges().first;
  runApp(ClubRamiroDAgnoneApp(isLoggedIn: user != null));
}

class ClubRamiroDAgnoneApp extends StatelessWidget {
  final bool isLoggedIn;

  const ClubRamiroDAgnoneApp({super.key, required this.isLoggedIn});

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
          home: isLoggedIn ? const MainShell() : const LoginScreen(),
        );
      },
    );
  }
}