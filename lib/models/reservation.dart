import "../utils/date_formatter.dart";

enum ReservationStatus { activa, completada, cancelada }

class Reservation {
  final String id;
  final String spaceId;
  final String sportEmoji;
  final String sportLabel; // ej: "FÚTBOL - F5"
  final String venueName; // ej: "Sede Morón"
  final String courtCode; // ej: "Cancha 1"
  final DateTime startAt;
  final DateTime endAt;
  final double price;
  final ReservationStatus status;

  const Reservation({
    required this.id,
    required this.spaceId,
    required this.sportEmoji,
    required this.sportLabel,
    required this.venueName,
    required this.courtCode,
    required this.startAt,
    required this.endAt,
    required this.price,
    required this.status,
  });

  // Returns a copy with some fields replaced.
  Reservation copyWith({ReservationStatus? status}) {
    return Reservation(
      id: id,
      spaceId: spaceId,
      sportEmoji: sportEmoji,
      sportLabel: sportLabel,
      venueName: venueName,
      courtCode: courtCode,
      startAt: startAt,
      endAt: endAt,
      price: price,
      status: status ?? this.status,
    );
  }
  
  // Derived values, so the screens do not change.
  DateTime get date => DateTime(startAt.year, startAt.month, startAt.day);
  String get timeRange => "${formatTime(startAt)} - ${formatTime(endAt)}";
}

