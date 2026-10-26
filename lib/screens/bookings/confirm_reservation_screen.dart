import "package:flutter/material.dart";
import "../../models/sport_space.dart";
import "../../models/time_slot.dart";
import "../../models/venue.dart";
import "../../services/booking_exceptions.dart";
import "../../services/reservation_service.dart";
import "../../utils/date_formatter.dart";

// What the screen tells the previous one when it closes.
enum ConfirmResult { booked, slotTaken }

class ConfirmReservationScreen extends StatefulWidget {
  final Venue venue;
  final SportSpace space;
  final TimeSlot slot;

  const ConfirmReservationScreen({
    super.key,
    required this.venue,
    required this.space,
    required this.slot,
  });

  @override
  State<ConfirmReservationScreen> createState() =>
      _ConfirmReservationScreenState();
}

class _ConfirmReservationScreenState extends State<ConfirmReservationScreen> {
  final _service = ReservationService();
  bool _isSubmitting = false;

  Future<void> _showMessage(String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isSubmitting = true);

    try {
      await _service.createReservation(
        space: widget.space,
        slot: widget.slot,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reserva confirmada")),
      );
      Navigator.of(context).pop(ConfirmResult.booked);
    } on SlotNotAvailableException {
      // Alternative flow 1 of CU-09: someone took the slot first.
      if (!mounted) return;
      await _showMessage(
        "Horario no disponible",
        "El horario seleccionado ya no está disponible. Por favor elegí otro turno.",
      );
      if (!mounted) return;
      Navigator.of(context).pop(ConfirmResult.slotTaken);
    } on InvalidBookingException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await _showMessage("No se pudo reservar", e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await _showMessage(
        "Error",
        "No pudimos completar la reserva. Intentá de nuevo más tarde.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final slot = widget.slot;
    final hours = slot.end.difference(slot.start).inHours;
    final total = space.pricePerHour * hours;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Confirmá tu reserva")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: colors.primary.withValues(alpha: 0.25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        space.displayName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.venue.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                _DetailRow(label: "Cancha", value: "Cancha ${space.number}"),
                const Divider(height: 1),
                _DetailRow(label: "Fecha", value: formatDate(slot.start)),
                const Divider(height: 1),
                _DetailRow(label: "Horario", value: slot.rangeLabel),
                const Divider(height: 1),
                _DetailRow(label: "Total", value: "\$${total.toStringAsFixed(0)}"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _onConfirm,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("CONFIRMAR RESERVA"),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error),
            ),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }
}

// Private: only used by this file.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}