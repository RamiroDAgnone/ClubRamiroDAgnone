import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "../../services/api_client.dart";
import "../../services/api_exceptions.dart";
import "../../services/auth_exceptions.dart";
import "../../utils/date_formatter.dart";
import "../../widgets/centered_form_layout.dart";
import "../../widgets/form_error_text.dart";

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _api = ApiClient();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  DateTime? _birthDate;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Google gives one "displayName": the first word is the first name.
    final parts = (FirebaseAuth.instance.currentUser?.displayName ?? "")
        .trim()
        .split(" ");
    _firstNameController = TextEditingController(text: parts.first);
    _lastNameController = TextEditingController(
      text: parts.length > 1 ? parts.skip(1).join(" ") : "",
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _onSavePressed() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _birthDate == null) {
      setState(() => _errorMessage = "Tenés que ingresar todos los datos");
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await _api.post("/users", {
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "birth_date": _birthDate!.toIso8601String().split("T").first,
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiConflictException {
      _showError("Ya existe un usuario registrado con ese email");
    } on NetworkException {
      _showError("No hay conexión a internet. Revisá tu red e intentá de nuevo");
    } catch (_) {
      _showError("Hubo un error en el servidor. Intentá de nuevo más tarde");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Completá tu perfil"),
        automaticallyImplyLeading: false,
      ),
      body: CenteredFormLayout(
        children: [
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: "Nombre"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(labelText: "Apellido"),
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
          const SizedBox(height: 8),
          // Leaving without a profile: the Firebase account stays, the next
          // login will ask for the data again.
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }
}