import "../models/reservation.dart";

// Temporary in-memory "database", shared by all the services.
// Delete this file when the real API is connected.
class MockDatabase {
  // `hour` o'clock, `daysFromNow` days from today (negative = past).
  static DateTime _at(int daysFromNow, int hour) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + daysFromNow, hour);
  }

  // Reservations of the logged user.
  static final List<Reservation> reservations = [
    Reservation(
      id: "1",
      spaceId: "s1",
      sportEmoji: "⚽",
      sportLabel: "FÚTBOL - F5",
      venueName: "Sede Morón",
      courtCode: "Cancha 1",
      startAt: _at(1, 18),
      endAt: _at(1, 19),
      price: 7600,
      status: ReservationStatus.activa,
    ),
    Reservation(
      id: "2",
      spaceId: "s13",
      sportEmoji: "🎾",
      sportLabel: "PADDLE",
      venueName: "Sede San Justo",
      courtCode: "Cancha 2",
      startAt: _at(3, 20),
      endAt: _at(3, 21),
      price: 6200,
      status: ReservationStatus.activa,
    ),
    Reservation(
      id: "3",
      spaceId: "s2",
      sportEmoji: "⚽",
      sportLabel: "FÚTBOL - F5",
      venueName: "Sede Morón",
      courtCode: "Cancha 2",
      startAt: _at(-5, 19),
      endAt: _at(-5, 20),
      price: 7600,
      status: ReservationStatus.completada,
    ),
    Reservation(
      id: "4",
      spaceId: "s12",
      sportEmoji: "🎾",
      sportLabel: "PADDLE",
      venueName: "Sede San Justo",
      courtCode: "Cancha 1",
      startAt: _at(-12, 21),
      endAt: _at(-12, 22),
      price: 6200,
      status: ReservationStatus.cancelada,
    ),
  ];

  // Time ranges already taken by OTHER users, for the next 7 days.
  static final othersBusy = <({String spaceId, DateTime start, DateTime end})>[
    for (var day = 0; day < 7; day++) ...[
      (spaceId: "s1", start: _at(day, 20), end: _at(day, 22)),
      (spaceId: "s3", start: _at(day, 21), end: _at(day, 22)),
      (spaceId: "s8", start: _at(day, 19), end: _at(day, 20)),
    ],
  ];

  // THE overlap rule: two ranges overlap when each one starts before the
  // other ends. 18-19 and 19-20 do NOT overlap (the end is exclusive).
  // Cancelled and finished reservations do not block the space.
  static bool hasOverlap(String spaceId, DateTime start, DateTime end) {
    bool overlaps(DateTime s, DateTime e) => start.isBefore(e) && s.isBefore(end);

    final mine = reservations.any(
      (r) =>
          r.spaceId == spaceId &&
          r.status == ReservationStatus.activa &&
          overlaps(r.startAt, r.endAt),
    );
    final others = othersBusy.any(
      (b) => b.spaceId == spaceId && overlaps(b.start, b.end),
    );
    return mine || others;
  }
}