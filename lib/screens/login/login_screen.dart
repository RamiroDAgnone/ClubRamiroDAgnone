import "package:flutter/material.dart";
import "../../widgets/centered_form_layout.dart";
import "../../widgets/form_error_text.dart";
import "../../widgets/password_field.dart";
import "../main_shell.dart";
import "forgot_password_screen.dart";
import "register_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Alternative flow 1 of CU-01: empty fields, nothing is sent to the backend.
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Tenés que ingresar tu email y contraseña");
      return;
    }

    setState(() => _errorMessage = null);

    // Temporary: later this will call the API (POST /auth/login).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CenteredFormLayout(
        children: [
          Text(
            "Club Ramiro D'Agnone",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          PasswordField(controller: _passwordController),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text("¿Olvidaste tu contraseña?"),
            ),
          ),
          FormErrorText(message: _errorMessage),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _onLoginPressed,
            child: const Text("Iniciar Sesión"),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
            child: const Text("¿Todavía no tenés cuenta? ¡Registrate!"),
          ),
        ],
      ),
    );
  }
}