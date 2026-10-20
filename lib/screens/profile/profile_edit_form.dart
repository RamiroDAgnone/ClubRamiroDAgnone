import "package:flutter/material.dart";
import "../../models/user.dart";
import "../../utils/date_formatter.dart";

class ProfileEditForm extends StatefulWidget {
  final User user;
  // Called with the updated user when the data is valid.
  final ValueChanged<User> onSave;
  final VoidCallback onCancel;

  const ProfileEditForm({
    super.key,
    required this.user,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _birthDateController;

  DateTime? _birthDate;
  // Becomes true after the first save attempt: from then on we show red/green borders.
  bool _submitted = false;
  String? _errorMessage;

  // Letters (with accents and ñ), spaces, apostrophes and hyphens only.
  static final _nameRegExp = RegExp(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ' -]+$");

  bool _isValidName(String text) => _nameRegExp.hasMatch(text.trim());

  bool get _isFirstNameValid => _isValidName(_firstNameController.text);
  bool get _isLastNameValid => _isValidName(_lastNameController.text);
  bool get _isBirthDateValid => _birthDate != null;

  @override
  void initState() {
    super.initState();
    // Fields start with the current user data.
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _birthDate = widget.user.birthDate;
    _birthDateController = TextEditingController(
      text: formatDate(widget.user.birthDate),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = formatDate(picked);
      });
    }
  }

  void _onSavePressed() {
    final isValid = _isFirstNameValid && _isLastNameValid && _isBirthDateValid;

    if (!isValid) {
      setState(() {
        _submitted = true;
        _errorMessage = "El formato de los datos no es válido";
      });
      return;
    }

    widget.onSave(
      widget.user.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _birthDate,
      ),
    );
  }

  // Normal look before the first save attempt; red or green borders afterwards.
  InputDecoration _decoration(String label, {required bool isValid}) {
    if (!_submitted) {
      return InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      );
    }
    final color = isValid ? Colors.green : Theme.of(context).colorScheme.error;
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: color, width: 2),
    );
    return InputDecoration(
      labelText: label,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _firstNameController,
          // Rebuild on every keystroke so the border color updates live.
          onChanged: (_) => setState(() {}),
          decoration: _decoration("Nombre", isValid: _isFirstNameValid),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _lastNameController,
          onChanged: (_) => setState(() {}),
          decoration: _decoration("Apellido", isValid: _isLastNameValid),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _birthDateController,
          readOnly: true,
          onTap: _pickBirthDate,
          decoration: _decoration(
            "Fecha de nacimiento",
            isValid: _isBirthDateValid,
          ).copyWith(suffixIcon: const Icon(Icons.calendar_today_outlined)),
        ),
        const SizedBox(height: 16),
        // Disabled field: the email cannot be edited.
        TextFormField(
          initialValue: widget.user.email,
          enabled: false,
          decoration: const InputDecoration(
            labelText: "Correo electrónico (no editable)",
            border: OutlineInputBorder(),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancel,
                child: const Text("CANCELAR"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _onSavePressed,
                child: const Text("GUARDAR"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}