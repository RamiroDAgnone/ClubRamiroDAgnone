import "package:flutter/material.dart";
import "../../services/auth_exceptions.dart";
import "../../services/auth_service.dart";
import "../../utils/date_formatter.dart";
import "../../widgets/centered_form_layout.dart";
import "../../widgets/form_error_text.dart";
import "../../widgets/password_field.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _authService = AuthService();
  bool _isLoading = false;

  DateTime? _birthDate;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

    void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Future<void> _onRegisterPressed() async {
    final hasEmptyField = _firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _birthDate == null;

    if (hasEmptyField) {
      setState(() => _errorMessage = "Tenés que ingresar todos los datos");
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
        await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _birthDate!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Cuenta creada correctamente!")),
      );
      Navigator.of(context).pop();
    } on EmailAlreadyInUseException {
      _showError("Ya existe una cuenta registrada con ese email");
    } on WeakPasswordException {
      _showError("La contraseña tiene que tener al menos 6 caracteres");
    } on InvalidEmailException {
      _showError("El email no es válido");
    } on NetworkException {
      _showError("No hay conexión a internet. Revisá tu red e intentá de nuevo");
    } catch (_) {
      _showError("Hubo un error en el servidor. Intentá de nuevo más tarde");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Cuenta")),
      body: CenteredFormLayout(
        children: [
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: "Nombre",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: "Apellido",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _pickBirthDate,
            child: Text(
              _birthDate == null
                  ? "Fecha de nacimiento"
                  : "Fecha de nacimiento: ${formatDate(_birthDate!)}",
            ),
          ),
          const SizedBox(height: 16),
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
          FormErrorText(message: _errorMessage),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _onRegisterPressed,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Crear Cuenta"),
          ),
        ],
      ),
    );
  }
}