import "package:flutter/material.dart";
import "../../models/user.dart";
import "../../utils/date_formatter.dart";

class ProfileInfoCard extends StatelessWidget {
  final User user;

  const ProfileInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _InfoRow(label: "Nombre", value: user.firstName),
          const Divider(height: 1),
          _InfoRow(label: "Apellido", value: user.lastName),
          const Divider(height: 1),
          _InfoRow(
            label: "Fecha de nacimiento",
            value: formatDate(user.birthDate),
          ),
          const Divider(height: 1),
          _InfoRow(
            label: "Correo electrónico (no editable)",
            value: user.email,
          ),
        ],
      ),
    );
  }
}

// Private: only used by this file.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}