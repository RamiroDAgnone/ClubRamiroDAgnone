import "package:flutter/material.dart";
import "../models/venue.dart";

class VenueQuickCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback? onTap;

  const VenueQuickCard({super.key, required this.venue, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 170,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 90,
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                child: const Icon(Icons.stadium_outlined, size: 32),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${venue.courtCount} canchas",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
