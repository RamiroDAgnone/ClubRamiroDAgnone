import "package:flutter/material.dart";
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

  void _onRegisterPressed() {
    final hasEmptyField = _firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _birthDate == null;

    // Alternative flow 1 of CU-03: incomplete data.
    if (hasEmptyField) {
      setState(() => _errorMessage = "Debes ingresar todos los datos");
      return;
    }

    setState(() => _errorMessage = null);

    // Temporary: later this will call the API to create the account.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("¡Cuenta creada correctamente!")),
    );
    Navigator.of(context).pop();
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
            onPressed: _onRegisterPressed,
            child: const Text("Crear Cuenta"),
          ),
        ],
      ),
    );
  }
}