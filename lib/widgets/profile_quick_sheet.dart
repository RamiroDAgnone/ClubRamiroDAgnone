import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../theme/app_theme.dart';

Future<void> showProfileQuickSheet(
  BuildContext context, {
  required UserProfile user,
  required VoidCallback onFullProfile,
  required VoidCallback onMyReservations,
  required VoidCallback onLogout,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.accent,
                    child: Text(
                      user.initials,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${user.firstName} ${user.lastName}',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Perfil completo'),
                onTap: () {
                  Navigator.pop(context);
                  onFullProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_note_outlined),
                title: const Text('Mis reservas'),
                onTap: () {
                  Navigator.pop(context);
                  onMyReservations();
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: AppTheme.danger),
                title: Text('Cerrar sesión', style: TextStyle(color: AppTheme.danger)),
                onTap: () {
                  Navigator.pop(context);
                  onLogout();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
