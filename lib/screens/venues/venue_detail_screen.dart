import "package:flutter/material.dart";
import "../../models/sport_space.dart";
import "../../models/venue.dart";
import "../../services/sport_space_service.dart";
import "../../widgets/sport_space_card.dart";
import "../bookings/available_slots_screen.dart";

class VenueDetailScreen extends StatefulWidget {
  final Venue venue;

  const VenueDetailScreen({super.key, required this.venue});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  final _service = SportSpaceService();
  late Future<List<SportSpace>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getSpacesByVenue(widget.venue.id);
  }

  void _reload() {
    setState(() {
    _future = _service.getSpacesByVenue(widget.venue.id);
    });
  }

  Future<void> _onViewSchedules(
    SportSpace space,
    List<SportSpace> allSpaces,
  ) async {
    // Courts of the same type, for the court selector of the next screen.
    final courts = allSpaces.where((s) => s.isSameTypeAs(space)).toList();
    final booked = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AvailableSlotsScreen(
          venue: widget.venue,
          space: space,
          courts: courts,
        ),
      ),
    );
    if (booked == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.venue.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Placeholder for the cover photo (later: Image.network).
          Container(
            height: 140,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            child: const Icon(Icons.stadium_outlined, size: 48),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.venue.address,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SportSpace>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("No pudimos cargar las canchas"),
                        TextButton(
                          onPressed: _reload,
                          child: const Text("Reintentar"),
                        ),
                      ],
                    ),
                  );
                }

                final spaces = snapshot.data ?? [];
                if (spaces.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "Esta sede todavía no tiene canchas disponibles",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  // +1: the first item is the "N canchas" title.
                  itemCount: spaces.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Text(
                        spaces.length == 1
                            ? "1 cancha"
                            : "${spaces.length} canchas",
                        style: Theme.of(context).textTheme.titleLarge,
                      );
                    }
                    final space = spaces[index - 1];
                    return SportSpaceCard(
                      space: space,
                      onViewSchedules: () => _onViewSchedules(space, spaces),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}