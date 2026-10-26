import "package:flutter/foundation.dart";
import "../models/reservation.dart";
import "../models/sport_space.dart";
import "../models/time_slot.dart";
import "api_client.dart";
import "api_exceptions.dart";
import "booking_exceptions.dart";

// Single entry point for the reservations of the logged user.
class ReservationService {
  // Goes up every time the reservations change, so open screens reload.
  static final ValueNotifier<int> changes = ValueNotifier(0);

  final _api = ApiClient();

  Future<List<Reservation>> getUpcomingReservations() => _getList("upcoming");

  Future<List<Reservation>> getReservationHistory() => _getList("history");

  Future<List<Reservation>> _getList(String scope) async {
    final json = await _api.getList("/bookings/me?scope=$scope");
    return json
        .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // The backend only needs 3 fields: the user comes from the token and the
  // price is calculated there. It validates every rule before saving.
  Future<Reservation> createReservation({
    required SportSpace space,
    required TimeSlot slot,
  }) async {
    try {
      final json = await _api.post("/bookings", {
        "sport_space_id": space.id,
        // UTC with "Z": no ambiguity about the time zone.
        "start_at": slot.start.toUtc().toIso8601String(),
        "end_at": slot.end.toUtc().toIso8601String(),
      });
      changes.value++;
      return Reservation.fromJson(json);
    } on ApiConflictException {
      // Alternative flow 1 of CU-09: someone took the slot first.
      throw const SlotNotAvailableException();
    } on ApiServerException catch (e) {
      if (e.statusCode == 400) {
        throw const InvalidBookingException(
          "La reserva no cumple las reglas del club: horas completas, horario futuro y dentro del horario de la sede.",
        );
      }
      rethrow;
    }
  }

  Future<void> cancelReservation(Reservation reservation) async {
    try {
      await _api.patch("/bookings/${reservation.id}/cancel");
      changes.value++;
    } on ApiServerException catch (e) {
      if (e.statusCode == 404) {
        throw const InvalidBookingException("La reserva ya no existe.");
      }
      // Alternative flow 4 of CU-10: past, in-progress or already cancelled.
      if (e.statusCode == 400) {
        throw const InvalidBookingException(
          "No es posible cancelar turnos pasados o en curso, ni reservas ya canceladas.",
        );
      }
      rethrow;
    }
  }
}