import "package:flutter/material.dart";
import "../../services/auth_exceptions.dart";
import "../../services/auth_service.dart";
import "../../widgets/centered_form_layout.dart";
import "../../widgets/form_error_text.dart";

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();

  String? _errorMessage;
  bool _isLoading = false;
  // false = request form, true = success confirmation.
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Future<void> _onSendPressed() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = "Tenés que ingresar tu correo electrónico");
      return;
    }

    // Basic format check: must contain "@" and a "." after it.
    final atIndex = email.indexOf("@");
    final isValidFormat =
        atIndex > 0 && email.indexOf(".", atIndex) > atIndex + 1;
    if (!isValidFormat) {
      setState(() => _errorMessage = "El correo electrónico no es válido");
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await _authService.sendPasswordReset(email);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } on InvalidEmailException {
      _showError("El correo electrónico no es válido");
    } on NetworkException {
      _showError("No hay conexión a internet. Revisá tu red e intentá de nuevo");
    } on TooManyRequestsException {
      _showError("Hiciste demasiados intentos. Esperá unos minutos e intentá de nuevo");
    } catch (e) {
      debugPrint("Password reset error: $e");
      _showError("Hubo un error en el servidor. Intentá de nuevo más tarde");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar contraseña")),
      body: CenteredFormLayout(
        // Show one view or the other depending on _emailSent.
        children: _emailSent ? _buildConfirmation() : _buildForm(),
      ),
    );
  }

  List<Widget> _buildForm() {
    return [
      Text(
        "Ingresá el correo con el que te registraste y te enviaremos un enlace para cambiar la contraseña.",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 24),
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: "Correo electrónico",
          border: OutlineInputBorder(),
        ),
      ),
      FormErrorText(message: _errorMessage),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: _isLoading ? null : _onSendPressed,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text("Enviar Enlace"),
      ),
    ];
  }

  List<Widget> _buildConfirmation() {
    return [
      Icon(
        Icons.mark_email_read_outlined,
        size: 64,
        color: Theme.of(context).colorScheme.primary,
      ),
      const SizedBox(height: 16),
      Text(
        "¡Correo enviado!",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      Text(
        "Si ${_emailController.text.trim()} tiene una cuenta, te llegará un correo con las instrucciones para cambiar tu contraseña. Revisá también la carpeta de spam.",
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("Volver al Inicio de Sesión"),
      ),
    ];
  }
}