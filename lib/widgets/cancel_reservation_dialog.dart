import "package:flutter/material.dart";
import "../models/reservation.dart";
import "../utils/date_formatter.dart";

// Returns true only if the user confirms the cancellation.
Future<bool> showCancelReservationDialog(
  BuildContext context,
  Reservation reservation,
) async {
  final colors = Theme.of(context).colorScheme;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("¿Querés cancelar la reserva?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${reservation.venueName} · ${reservation.courtCode}",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text("${formatDate(reservation.date)} · ${reservation.timeRange}"),
          Text("\$${reservation.price.toStringAsFixed(0)}"),
          const SizedBox(height: 12),
          const Text(
            "El horario va a quedar disponible para otros usuarios.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Volver"),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text("Cancelar reserva"),
        ),
      ],
    ),
  );

  // Tapping outside the dialog returns null: that also means "no".
  return confirmed == true;
}