import "package:flutter/material.dart";
import "../../models/venue.dart";
import "../../services/venue_service.dart";
import "../../widgets/venue_card.dart";
import "venue_detail_screen.dart";

class VenuesScreen extends StatefulWidget {
  // Called when a reservation was created, so the shell can show "Reservas".
  final VoidCallback? onReservationCreated;

  const VenuesScreen({super.key, this.onReservationCreated});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  final _service = VenueService();
  late Future<List<Venue>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getVenues();
  }

  void _reload() {
    setState(() => _future = _service.getVenues());
  }

  Future<void> _onViewCourts(Venue venue) async {
    final booked = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => VenueDetailScreen(venue: venue)),
    );
    if (booked == true && mounted) {
      widget.onReservationCreated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Sedes",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Venue>>(
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
                        const Text("No pudimos cargar las sedes"),
                        TextButton(
                          onPressed: _reload,
                          child: const Text("Reintentar"),
                        ),
                      ],
                    ),
                  );
                }

                final venues = snapshot.data ?? [];
                if (venues.isEmpty) {
                  return Center(
                    child: Text(
                      "Todavía no hay sedes disponibles",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: venues.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final venue = venues[index];
                    return VenueCard(
                      venue: venue,
                      onViewCourts: () => _onViewCourts(venue),
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