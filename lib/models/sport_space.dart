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

  // Same venue, sport and variant (e.g. Fútbol F5 Cancha 1 and Cancha 2).
  bool isSameTypeAs(SportSpace other) =>
    venueId == other.venueId && sport == other.sport && variant == other.variant;

  String get emoji {
    switch (sport) {
      case "Fútbol":
        return "⚽";
      case "Paddle":
        return "🎾";
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
}