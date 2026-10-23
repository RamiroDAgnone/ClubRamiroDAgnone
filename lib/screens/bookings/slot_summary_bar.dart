import "package:flutter/material.dart";
import "../../models/sport_space.dart";
import "../../models/time_slot.dart";

// Bottom bar: summary of the chosen slot and the button to continue.
class SlotSummaryBar extends StatelessWidget {
  final SportSpace space;
  final TimeSlot? slot;
  final int durationHours;
  final VoidCallback onContinue;

  const SlotSummaryBar({
    super.key,
    required this.space,
    required this.slot,
    required this.durationHours,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final chosen = slot;
    final total = space.pricePerHour * durationHours;

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (chosen == null)
                const Text(
                  "Seleccioná un horario",
                  style: TextStyle(color: Colors.grey),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${space.displayName} · Cancha ${space.number}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(chosen.rangeLabel),
                        ],
                      ),
                    ),
                    Text(
                      "\$${total.toStringAsFixed(0)}",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              FilledButton(
                // null = disabled until there is a valid selection.
                onPressed: chosen == null ? null : onContinue,
                child: const Text("Reservar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}