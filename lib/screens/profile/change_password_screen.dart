import "package:flutter/material.dart";
import "../../services/auth_exceptions.dart";
import "../../services/auth_service.dart";
import "../../widgets/centered_form_layout.dart";
import "../../widgets/form_error_text.dart";
import "../../widgets/password_field.dart";

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Future<void> _onSavePressed() async {
    final current = _currentController.text;
    final newPassword = _newController.text;

    if (current.isEmpty || newPassword.isEmpty || _confirmController.text.isEmpty) {
      setState(() => _errorMessage = "Tenés que completar los tres campos");
      return;
    }
    if (newPassword != _confirmController.text) {
      setState(() => _errorMessage = "Las contraseñas nuevas no coinciden");
      return;
    }
    if (newPassword == current) {
      setState(() => _errorMessage = "La contraseña nueva tiene que ser distinta de la actual");
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await _authService.changePassword(
        currentPassword: current,
        newPassword: newPassword,
      );
      if (!mounted) return;
      // The profile screen shows the confirmation message.
      Navigator.of(context).pop(true);
    } on InvalidCredentialsException {
      _showError("La contraseña actual no es correcta");
    } on WeakPasswordException {
      _showError("La contraseña nueva tiene que tener al menos 6 caracteres");
    } on NetworkException {
      _showError("No hay conexión a internet. Revisá tu red e intentá de nuevo");
    } on TooManyRequestsException {
      _showError("Hiciste demasiados intentos. Esperá unos minutos e intentá de nuevo");
    } catch (e) {
      debugPrint("Change password error: $e");
      _showError("Hubo un error en el servidor. Intentá de nuevo más tarde");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cambiar contraseña")),
      body: CenteredFormLayout(
        children: [
          PasswordField(controller: _currentController, label: "Contraseña actual"),
          const SizedBox(height: 16),
          PasswordField(controller: _newController, label: "Contraseña nueva"),
          const SizedBox(height: 16),
          PasswordField(
            controller: _confirmController,
            label: "Repetí la contraseña nueva",
          ),
          FormErrorText(message: _errorMessage),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _onSavePressed,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}