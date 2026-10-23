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

  // e.g. "18:00 - 19:00"
  String get rangeLabel => "${formatTime(start)} - ${formatTime(end)}";
}