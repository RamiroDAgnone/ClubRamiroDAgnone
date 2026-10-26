import "package:flutter/material.dart";
import "../services/auth_exceptions.dart";
import "../models/user.dart";
import "../services/user_service.dart";
import "home/home_screen.dart";
import "profile/profile_screen.dart";
import "../theme/app_theme.dart";
import "bookings/reservations_screen.dart";
import "venues/venues_screen.dart";
import "../utils/session.dart";
import "../widgets/centered_form_layout.dart";
import "../services/notification_service.dart";

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _userService = UserService();
  final _notificationService = NotificationService();

  int _selectedIndex = 0;
  // null while the user is still loading.
  User? _user;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _errorMessage = null);
    try {
      final user = await _userService.getCurrentUser();
      if (!mounted) return;
      setState(() => _user = user);
      _notificationService.registerDevice();
    } on NetworkException {
      if (!mounted) return;
      setState(() => _errorMessage =
          "No hay conexión a internet. Revisá tu red e intentá de nuevo");
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage =
          "Hubo un error en el servidor. Intentá de nuevo más tarde");
    }
  }

  Future<void> _updateUser(User updated) async {
    final saved = await _userService.updateUser(updated);
    if (!mounted) return;
    setState(() => _user = saved);
  }

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    // While the user loads we show a spinner instead of the app.
    if (user == null) {
      final error = _errorMessage;
      if (error == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        body: CenteredFormLayout(
          children: [
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: _loadUser, child: const Text("Reintentar")),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => logout(context),
              child: const Text("Cerrar sesión"),
            ),
          ],
        ),
      );
    }

    final screens = [
      HomeScreen(
        user: user,
        onGoToReservas: () => _goToTab(1),
        onGoToSedes: () => _goToTab(2),
        onGoToPerfil: () => _goToTab(3),
      ),
      const ReservationsScreen(),
      VenuesScreen(onReservationCreated: () => _goToTab(1)),
      ProfileScreen(user: user, onUserUpdated: _updateUser),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _goToTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        unselectedItemColor: Colors.grey,
        selectedItemColor: AppTheme.accent,
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