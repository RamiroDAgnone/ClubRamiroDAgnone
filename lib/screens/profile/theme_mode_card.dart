import "package:flutter/material.dart";
import "../../theme/theme_controller.dart";

class ThemeModeCard extends StatelessWidget {
  const ThemeModeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) {
          return SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text("Modo oscuro"),
            value: mode == ThemeMode.dark,
            onChanged: (isDark) {
              themeModeNotifier.value =
                  isDark ? ThemeMode.dark : ThemeMode.light;
            },
          );
        },
      ),
    );
  }
}