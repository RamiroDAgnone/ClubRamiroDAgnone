import "package:flutter/material.dart";
import "home/home_screen.dart";

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onGoToReservas: () => _goToTab(1),
        onGoToSedes: () => _goToTab(2),
        onGoToPerfil: () => _goToTab(3),
      ),
      const _PlaceholderScreen(title: "Mis Reservas"),
      const _PlaceholderScreen(title: "Sedes"),
      const _PlaceholderScreen(title: "Perfil"),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _goToTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: "Reservas"),
          BottomNavigationBarItem(icon: Icon(Icons.stadium_outlined), label: "Sedes"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Perfil"),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          "$title (próximamente)",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}