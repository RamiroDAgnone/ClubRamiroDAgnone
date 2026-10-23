import "package:flutter/material.dart";
import "../models/sport_space.dart";

class SportSpaceCard extends StatelessWidget {
  final SportSpace space;
  final VoidCallback? onViewSchedules;

  const SportSpaceCard({super.key, required this.space, this.onViewSchedules});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(space.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${space.displayName} · Cancha ${space.number}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              space.name,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontFamily: "monospace",
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Text(
                  "\$${space.pricePerHour.toStringAsFixed(0)} / hora",
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: onViewSchedules,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text("Ver horarios / Reservar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}