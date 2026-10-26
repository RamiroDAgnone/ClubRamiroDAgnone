class Venue {
  final String id;
  final String name;
  final String address;
  final String openingTime; // e.g. "08:00"
  final String closingTime; // e.g. "23:00"
  final int courtCount;
  final List<String> sports;

  const Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.openingTime,
    required this.closingTime,
    required this.courtCount,
    required this.sports,
  });

  // e.g. "08:00 - 23:00"
  String get hoursLabel => "$openingTime - $closingTime";

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json["id"] as String,
      name: json["name"] as String,
      address: json["address"] as String,
      // The API sends "08:00:00": we keep only "08:00".
      openingTime: (json["opening_time"] as String).substring(0, 5),
      closingTime: (json["closing_time"] as String).substring(0, 5),
      courtCount: json["court_count"] as int,
      sports: List<String>.from(json["sports"] as List),
    );
  }
}