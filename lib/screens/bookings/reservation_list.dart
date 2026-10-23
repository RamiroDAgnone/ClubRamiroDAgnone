import "package:flutter/material.dart";
import "../../models/reservation.dart";
import "../../widgets/reservation_card.dart";
import "../../services/reservation_service.dart";

// Loads and shows a list of reservations. Which ones depends on the loader.
class ReservationList extends StatefulWidget {
  final Future<List<Reservation>> Function() loader;
  final String emptyText;

  const ReservationList({
    super.key,
    required this.loader,
    required this.emptyText,
  });

  @override
  State<ReservationList> createState() => _ReservationListState();
}

class _ReservationListState extends State<ReservationList> {
  late Future<List<Reservation>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
    ReservationService.changes.addListener(_reload);
  }

  @override
  void dispose() {
    ReservationService.changes.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() => _future = widget.loader());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reservation>>(
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
                const Text("No pudimos cargar tus reservas"),
                TextButton(
                  onPressed: _reload,
                  child: const Text("Reintentar"),
                ),
              ],
            ),
          );
        }

        final reservations = snapshot.data ?? [];
        if (reservations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                widget.emptyText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: reservations.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return ReservationCard(
              reservation: reservations[index],
              width: double.infinity,
            );
          },
        );
      },
    );
  }
}