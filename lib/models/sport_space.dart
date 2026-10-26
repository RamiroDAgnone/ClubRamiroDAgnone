class SportSpace {
  final String id;
  final String venueId;
  final String sport; // e.g. "Fútbol", "Paddle"
  final String? variant; // e.g. "F5", "F11" (null if the sport has none)
  final int number;
  final String name; // technical name, e.g. "Moron_Rivadavia_19850_Futbol_F5_1"
  final double pricePerHour;

  const SportSpace({
    required this.id,
    required this.venueId,
    required this.sport,
    required this.variant,
    required this.number,
    required this.name,
    required this.pricePerHour,
  });

  // e.g. "Fútbol F5" or "Paddle".
  String get displayName => variant == null ? sport : "$sport $variant";
  String get emoji => sportEmoji(sport);

  // Same venue, sport and variant (e.g. Fútbol F5 Cancha 1 and Cancha 2).
  bool isSameTypeAs(SportSpace other) =>
    venueId == other.venueId && sport == other.sport && variant == other.variant;
  
  factory SportSpace.fromJson(Map<String, dynamic> json) {
    return SportSpace(
      id: json["id"] as String,
      venueId: json["venue_id"] as String,
      sport: json["sport"] as String,
      variant: json["variant"] as String?,
      number: json["number"] as int,
      name: json["name"] as String,
      pricePerHour: (json["price_per_hour"] as num).toDouble(),
    );
  }
  
}

String sportEmoji(String sport) {
  switch (sport) {
    case "Fútbol":
      return "⚽";
    case "Paddle":
    case "Tenis":
      return "🎾";
    case "Básquet":
      return "🏀";
    case "Vóley":
      return "🏐";
    case "Hockey":
      return "🏑";
    default:
      return "🏟️";
  }
}