import "package:flutter/material.dart";
import "../../models/reservation.dart";
import "../../models/user.dart";
import "../../models/venue.dart";
import "../../services/reservation_service.dart";
import "../../services/venue_service.dart";
import "../../theme/app_theme.dart";
import "../../utils/session.dart";
import "../../widgets/profile_quick_sheet.dart";
import "../../widgets/reservation_card.dart";
import "../../widgets/venue_quick_card.dart";

class HomeScreen extends StatefulWidget {
  // Callbacks para navegar a otras tabs sin acoplar el Home a la lógica del shell.
  final VoidCallback? onGoToReservas;
  final VoidCallback? onGoToSedes;
  final VoidCallback? onGoToPerfil;

  final User user;

  const HomeScreen({
    super.key,
    required this.user,
    this.onGoToReservas,
    this.onGoToSedes,
    this.onGoToPerfil,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _reservationService = ReservationService();
  final _venueService = VenueService();

    late Future<List<Reservation>> _reservationsFuture;
  late final Future<List<Venue>> _venuesFuture;

  @override
  void initState() {
    super.initState();
    _reservationsFuture = _reservationService.getUpcomingReservations();
    _venuesFuture = _venueService.getVenues();
    ReservationService.changes.addListener(_reloadReservations);
  }

  @override
  void dispose() {
    ReservationService.changes.removeListener(_reloadReservations);
    super.dispose();
  }

  void _reloadReservations() {
    setState(() {
      _reservationsFuture = _reservationService.getUpcomingReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ---- Header: saludo + avatar ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hola,", style: TextStyle(color: Colors.grey)),
                      Text(user.firstName, style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => showProfileQuickSheet(
                      context,
                      user: user,
                      onFullProfile: () => widget.onGoToPerfil?.call(),
                      onMyReservations: () => widget.onGoToReservas?.call(),
                      onLogout: () => logout(context),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.accent,
                      child: Text(
                        user.initials,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- Sección: Próximas reservas ----
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: "Próximas reservas",
              actionLabel: "Ver todas",
              onAction: widget.onGoToReservas,
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Reservation>>(
              future: _reservationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _LoadingBox();
                }
                final reservations = snapshot.data ?? [];
                if (reservations.isEmpty) {
                  return const _EmptyHint(
                    text: "No tenés reservas próximas todavía.",
                  );
                }
                return SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: reservations.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return ReservationCard(reservation: reservations[index]);
                    },
                  ),
                );
              },
            ),
          ),

          // ---- Sección: Sedes ----
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: "Sedes",
              actionLabel: "Ver todas",
              onAction: widget.onGoToSedes,
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Venue>>(
              future: _venuesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _LoadingBox();
                }
                final venues = snapshot.data ?? [];
                return SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: venues.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return VenueQuickCard(venue: venues[index]);
                    },
                  ),
                );
              },
            ),
          ),
          // ---- Acceso rápido: Reservar ahora ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: widget.onGoToSedes,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    "Reservar una cancha",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 150,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}