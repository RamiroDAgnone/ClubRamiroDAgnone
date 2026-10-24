import "package:flutter/material.dart";
import "../../services/reservation_service.dart";
import "../../theme/app_theme.dart";
import "reservation_list.dart";

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final _service = ReservationService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Mis reservas",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            TabBar(
              labelColor: Theme.of(context).colorScheme.onSurface,
              indicatorColor: AppTheme.accent,
              tabs: const [
                Tab(text: "Próximas"),
                Tab(text: "Historial"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ReservationList(
                    loader: _service.getUpcomingReservations,
                    emptyText:
                        "No se encontraron próximas reservas asociadas a tu cuenta",
                    canCancel: true,
                  ),
                  ReservationList(
                    loader: _service.getReservationHistory,
                    emptyText:
                        "No se encontraron reservas pasadas asociadas a tu cuenta",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}