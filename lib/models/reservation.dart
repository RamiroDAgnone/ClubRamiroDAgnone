import "../utils/date_formatter.dart";
//import "sport_space.dart";

enum ReservationStatus { activa, completada, cancelada }

class Reservation {
  final String id;
  final String spaceId;
  //final String sportEmoji;
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
    //required this.sportEmoji,
    required this.sportLabel,
    required this.venueName,
    required this.courtCode,
    required this.startAt,
    required this.endAt,
    required this.price,
    required this.status,
  });

  // Returns a copy with some fields replaced.
    factory Reservation.fromJson(Map<String, dynamic> json) {
    final sport = json["sport"] as String;
    final variant = json["variant"] as String?;
    final upperSport = sport.toUpperCase();

    return Reservation(
      id: json["id"] as String,
      spaceId: json["sport_space_id"] as String,
      //sportEmoji: sportEmoji(sport),
      sportLabel: variant == null ? upperSport : "$upperSport - $variant",
      venueName: json["venue_name"] as String,
      courtCode: "Cancha ${json["space_number"]}",
      startAt: DateTime.parse(json["start_at"] as String).toLocal(),
      endAt: DateTime.parse(json["end_at"] as String).toLocal(),
      price: (json["price"] as num).toDouble(),
      status: switch (json["status"] as String) {
        "active" => ReservationStatus.activa,
        "completed" => ReservationStatus.completada,
        _ => ReservationStatus.cancelada,
      },
    );
  }
  
  // Derived values, so the screens do not change.
  DateTime get date => DateTime(startAt.year, startAt.month, startAt.day);
  String get timeRange => "${formatTime(startAt)} - ${formatTime(endAt)}";
}

