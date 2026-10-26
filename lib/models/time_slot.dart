import "../utils/date_formatter.dart";

class TimeSlot {
  final DateTime start;
  final DateTime end;
  final bool isAvailable;

  const TimeSlot({
    required this.start,
    required this.end,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      // The API sends the time with its offset; toLocal() gives the device time.
      start: DateTime.parse(json["start_at"] as String).toLocal(),
      end: DateTime.parse(json["end_at"] as String).toLocal(),
      isAvailable: json["is_available"] as bool,
    );
  }

  // e.g. "18:00 - 19:00"
  String get rangeLabel => "${formatTime(start)} - ${formatTime(end)}";
}