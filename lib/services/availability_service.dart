import "../models/time_slot.dart";
import "mock_database.dart";

// Single entry point for the availability of a sport space.
// The real API calculates this in the backend. Here we fake it.
class AvailabilityService {
  // Mock: the real API reads the venue opening hours from the database.
  static const _openingHour = 8;
  static const _closingHour = 23;

  // Later: GET /sport-spaces/{spaceId}/availability?date=2026-10-23&duration=1
  Future<List<TimeSlot>> getSlots({
    required String spaceId,
    required DateTime date,
    required int durationHours,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final slots = <TimeSlot>[];

    // The end can never go past the closing hour.
    for (var hour = _openingHour; hour + durationHours <= _closingHour; hour++) {
      final start = DateTime(date.year, date.month, date.day, hour);
      final end = start.add(Duration(hours: durationHours));

      // Free = in the future and not overlapping any active reservation.
      final isFree =
          start.isAfter(now) && !MockDatabase.hasOverlap(spaceId, start, end);

      slots.add(TimeSlot(start: start, end: end, isAvailable: isFree));
    }
    return slots;
  }
}