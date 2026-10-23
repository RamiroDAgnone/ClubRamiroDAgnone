class Venue {
  final String id;
  final String name;
  final String address;
  final int courtCount;
  final List<String> sports;

  const Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.courtCount,
    required this.sports,
  });
}