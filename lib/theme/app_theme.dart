import "package:flutter/material.dart";

// Colors that change between light and dark mode.
class _Palette {
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color text;
  final Color secondaryText;
  final Color muted;
  // Accent-like color that stays readable on this mode's surfaces
  // (lime on dark, black on light).
  final Color emphasis;
  final Color border;

  const _Palette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.text,
    required this.secondaryText,
    required this.muted,
    required this.emphasis,
    required this.border,
  });
}

// Single place where the look of the whole app is defined.
// Screens and widgets must take colors and shapes from the theme, not hardcode them.
class AppTheme {
  // Brand colors (same in both modes).
  static const Color accent = Color(0xFFD4FF3D); // lime
  static const Color danger = Color(0xFFE5484D);

  static const double buttonRadius = 14;
  static const double cardRadius = 18;
  static const double inputRadius = 12;

  static const _dark = _Palette(
    brightness: Brightness.dark,
    background: Color(0xFF121212),
    surface: Color(0xFF1E1F22),
    text: Colors.white,
    secondaryText: Colors.white70,
    muted: Color(0xFF9E9E9E),
    emphasis: accent,
    border: Color(0xFF3A3B3F),
  );

  static const _light = _Palette(
    brightness: Brightness.light,
    background: Color(0xFFF7F7F8),
    surface: Colors.white,
    text: Colors.black,
    secondaryText: Colors.black87,
    muted: Color(0xFF757575),
    emphasis: Colors.black,
    border: Color(0xFFD9D9DE),
  );

  static ThemeData get dark => _build(_dark);
  static ThemeData get light => _build(_light);

  static ThemeData _build(_Palette p) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: p.brightness,
    ).copyWith(
      primary: accent,
      onPrimary: Colors.black,
      error: danger,
      onSurfaceVariant: p.muted,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(cardRadius),
    );
    const buttonPadding = EdgeInsets.symmetric(vertical: 16);
    const buttonText = TextStyle(fontWeight: FontWeight.w700);

    OutlineInputBorder inputBorder(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: p.text,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: p.emphasis,
        unselectedItemColor: p.muted,
        type: BottomNavigationBarType.fixed,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          side: BorderSide(color: p.border),
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.emphasis),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        border: inputBorder(p.border, 1),
        enabledBorder: inputBorder(p.border, 1),
        focusedBorder: inputBorder(p.emphasis, 2),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.emphasis,
        selectionHandleColor: p.emphasis,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.emphasis),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: buttonShape,
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: p.text),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: p.text),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: p.text),
        bodyMedium: TextStyle(color: p.secondaryText),
      ),
    );
  }
}