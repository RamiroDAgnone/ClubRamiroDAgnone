import "package:flutter/material.dart";
import "../theme/app_theme.dart";

class AccentChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onSelected;

  const AccentChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected == null ? null : (_) => onSelected!(),
      selectedColor: AppTheme.accent,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? Colors.black : null,
      ),
    );
  }
}