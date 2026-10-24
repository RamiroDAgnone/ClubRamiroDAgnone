import "package:flutter/foundation.dart";
import "../models/reservation.dart";
import "../models/sport_space.dart";
import "../models/time_slot.dart";
import "../models/venue.dart";
import "booking_exceptions.dart";
import "mock_database.dart";

// Single entry point for the reservations of the logged user.
class ReservationService {
  // Goes up every time the reservations change, so open screens reload.
  static final ValueNotifier<int> changes = ValueNotifier(0);

  // Later: GET /bookings/me?scope=upcoming
  Future<List<Reservation>> getUpcomingReservations() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockDatabase.reservations
        .where((r) => r.status == ReservationStatus.activa)
        .toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
  }

  // Later: GET /bookings/me?scope=history
  Future<List<Reservation>> getReservationHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockDatabase.reservations
        .where((r) => r.status != ReservationStatus.activa)
        .toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
  }

  // Later: POST /bookings  { sport_space_id, start_at, end_at }
  // The real backend only receives those 3 fields and builds the rest.
  Future<Reservation> createReservation({
    required Venue venue,
    required SportSpace space,
    required TimeSlot slot,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Same rules the real backend validates before saving.
    if (slot.start.minute != 0 || slot.end.minute != 0) {
      throw const InvalidBookingException(
        "Los horarios deben comenzar y finalizar en hora completa.",
      );
    }
    if (slot.end.difference(slot.start) < const Duration(hours: 1)) {
      throw const InvalidBookingException(
        "La duración mínima de una reserva es de una hora.",
      );
    }
    if (!slot.start.isAfter(DateTime.now())) {
      throw const InvalidBookingException(
        "La reserva debe ser para un horario futuro.",
      );
    }
    if (MockDatabase.hasOverlap(space.id, slot.start, slot.end)) {
      throw const SlotNotAvailableException();
    }

    final hours = slot.end.difference(slot.start).inHours;
    final sport = space.sport.toUpperCase();
    final reservation = Reservation(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      spaceId: space.id,
      sportEmoji: space.emoji,
      sportLabel: space.variant == null ? sport : "$sport - ${space.variant}",
      venueName: venue.name,
      courtCode: "Cancha ${space.number}",
      startAt: slot.start,
      endAt: slot.end,
      price: space.pricePerHour * hours,
      status: ReservationStatus.activa,
    );

    MockDatabase.reservations.add(reservation);
    changes.value++;
    return reservation;
  }
  
  // Later: PATCH /bookings/{id}/cancel
  Future<void> cancelReservation(Reservation reservation) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Like the real backend: it only trusts the id and checks its own data.
    final index = MockDatabase.reservations.indexWhere(
      (r) => r.id == reservation.id,
    );
    if (index == -1) {
      throw const InvalidBookingException("La reserva ya no existe.");
    }

    final current = MockDatabase.reservations[index];
    if (current.status != ReservationStatus.activa) {
      throw const InvalidBookingException(
        "La reserva ya fue cancelada o finalizó.",
      );
    }
    // Alternative flow 4 of CU-10: past or in-progress slots.
    if (!current.startAt.isAfter(DateTime.now())) {
      throw const InvalidBookingException(
        "No es posible cancelar turnos pasados o en curso.",
      );
    }

    MockDatabase.reservations[index] =
        current.copyWith(status: ReservationStatus.cancelada);
    changes.value++;
  }
}