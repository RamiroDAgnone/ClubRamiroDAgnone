import "package:flutter/material.dart";
import "../models/venue.dart";

class VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback? onViewCourts;

  const VenueCard({super.key, required this.venue, this.onViewCourts});

  @override
  Widget build(BuildContext context) {
    final courtsText =
        venue.courtCount == 1 ? "1 cancha" : "${venue.courtCount} canchas";

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Placeholder for the venue photo (later: Image.network).
          Container(
            height: 140,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            child: const Icon(Icons.stadium_outlined, size: 48),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue.address,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final sport in venue.sports)
                      Chip(
                        label: Text(sport, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      courtsText,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onViewCourts,
                      child: const Text("Ver canchas"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}