import "package:flutter/material.dart";
import "../models/reservation.dart";
import "../theme/app_theme.dart";

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onTap; // el "onClick" de Flutter

  const ReservationCard({super.key, required this.reservation, this.onTap});

  Color _statusColor() {
    switch (reservation.status) {
      case ReservationStatus.activa:
        return AppTheme.accent;
      case ReservationStatus.completada:
        return Colors.grey;
      case ReservationStatus.cancelada:
        return AppTheme.danger;
    }
  }

  String _statusLabel() {
    switch (reservation.status) {
      case ReservationStatus.activa:
        return "Activa";
      case ReservationStatus.completada:
        return "Completada";
      case ReservationStatus.cancelada:
        return "Cancelada";
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fila superior: emoji + deporte + badge de estado
              Row(
                children: [
                  Text(reservation.sportEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reservation.sportLabel,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(),
                      style: TextStyle(
                        color: statusColor == AppTheme.accent ? Colors.black87 : statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(reservation.venueName, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                "${reservation.courtCode} · ${reservation.timeRange}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(reservation.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    "\$${reservation.price.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const dias = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
    return "${dias[d.weekday - 1]} ${d.day}/${d.month}";
  }
}
