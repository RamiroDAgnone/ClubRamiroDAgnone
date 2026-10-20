import "package:flutter/material.dart";
import "../../widgets/centered_form_layout.dart";
import "../../widgets/form_error_text.dart";

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  String? _errorMessage;
  // false = request form, true = success confirmation.
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendPressed() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = "Debes ingresar tu correo electrónico");
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

    // Temporary: later this will ask Firebase to send the recovery email.
    setState(() {
      _errorMessage = null;
      _emailSent = true;
    });
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
        "Ingresa el correo con el que te registraste y te enviaremos un enlace para cambiar la contraseña.",
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
        onPressed: _onSendPressed,
        child: const Text("Enviar Enlace"),
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
        "Revisa tu bandeja de entrada en ${_emailController.text.trim()} y sigue las instrucciones para cambiar tu contraseña.",
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