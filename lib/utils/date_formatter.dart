String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, "0");
  final month = date.month.toString().padLeft(2, "0");
  return "$day/$month/${date.year}";
}

String formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, "0");
  final minute = date.minute.toString().padLeft(2, "0");
  return "$hour:$minute";
}

String formatDayChip(DateTime date) {
  const days = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
  return "${days[date.weekday - 1]} ${date.day}";
}