import "package:flutter/material.dart";
import "../../models/time_slot.dart";
import "../../widgets/accent_choice_chip.dart";

class SlotGrid extends StatelessWidget {
  final Future<List<TimeSlot>> future;
  final TimeSlot? selected;
  final ValueChanged<TimeSlot> onSelect;
  final VoidCallback onRetry;

  const SlotGrid({
    super.key,
    required this.future,
    required this.selected,
    required this.onSelect,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TimeSlot>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Text("No pudimos cargar los horarios"),
                TextButton(onPressed: onRetry, child: const Text("Reintentar")),
              ],
            ),
          );
        }

        final slots = snapshot.data ?? [];
        final unavailableCount = slots.where((s) => !s.isAvailable).length;

        // Alternative flow 4: nothing free for this court, date and duration.
        if (unavailableCount == slots.length) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  "No hay horarios disponibles",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Probá con otra fecha",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final slot in slots)
                  AccentChoiceChip(
                    label: slot.rangeLabel,
                    selected: selected?.start == slot.start,
                    onSelected: slot.isAvailable ? () => onSelect(slot) : null,
                  ),
              ],
            ),
            if (unavailableCount > 0) ...[
              const SizedBox(height: 12),
              Text(
                "Algunos horarios están ocupados · $unavailableCount no disponibles",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        );
      },
    );
  }
}