import "package:flutter/material.dart";
import "../../services/auth_exceptions.dart";
import "../../models/user.dart";
import "../../utils/session.dart";
import "profile_edit_form.dart";
import "profile_header.dart";
import "profile_info_card.dart";
import "theme_mode_card.dart";

class ProfileScreen extends StatefulWidget {
  final User user;

  // Called when the user saves valid changes. The parent decides how to store them.
  final Future<void> Function(User) onUserUpdated;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  Future<void> _onSave(User updated) async {
    try {
      await widget.onUserUpdated(updated);
    } on NetworkException {
      _showSnack("No hay conexión a internet. Revisá tu red e intentá de nuevo");
      return;
    } catch (_) {
      _showSnack("Hubo un error en el servidor. Intentá de nuevo más tarde");
      return;
    }
    // The screen may have been closed while we were waiting.
    if (!mounted) return;
    setState(() => _isEditing = false);
    _showSnack("Perfil actualizado correctamente");
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ProfileHeader(user: widget.user),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    "Datos personales",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (!_isEditing)
                    TextButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text("Editar"),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isEditing)
                ProfileEditForm(
                  user: widget.user,
                  onSave: _onSave,
                  onCancel: () => setState(() => _isEditing = false),
                )
              else
                ProfileInfoCard(user: widget.user),
              if (!_isEditing) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text("Seguridad"),                    
                    subtitle: const Text("Cambiar contraseña"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Disponible próximamente")),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const ThemeModeCard(),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => logout(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error),
                  ),
                  child: const Text("Cerrar sesión"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}