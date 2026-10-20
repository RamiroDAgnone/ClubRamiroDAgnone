enum ReservationStatus { activa, completada, cancelada }

class Reservation {
  final String id;
  final String sportEmoji;
  final String sportLabel; // ej: "FÚTBOL - FÚTBOL 5"
  final String venueName; // ej: "Sede Morón"
  final String courtCode; // ej: "Cancha 1"
  final DateTime date;
  final String timeRange; // ej: "18:00 - 19:00"
  final double price;
  final ReservationStatus status;

  const Reservation({
    required this.id,
    required this.sportEmoji,
    required this.sportLabel,
    required this.venueName,
    required this.courtCode,
    required this.date,
    required this.timeRange,
    required this.price,
    required this.status,
  });
}

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

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String membershipStatus;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.membershipStatus,
  });

  String get initials =>
      "${firstName.isNotEmpty ? firstName[0] : ""}${lastName.isNotEmpty ? lastName[0] : ""}"
          .toUpperCase();
}

// ---- MOCK DATA (borrar cuando conectes la API) ----

const mockUser = UserProfile(
  firstName: "Ramiro",
  lastName: "D'Agnone",
  email: "ramiro.dagnone@gmail.com",
  membershipStatus: "Miembro activo",
);

final mockReservations = <Reservation>[
  Reservation(
    id: "1",
    sportEmoji: "⚽",
    sportLabel: "FÚTBOL - FÚTBOL 5",
    venueName: "Sede Morón",
    courtCode: "Cancha 1",
    date: DateTime.now().add(const Duration(days: 1)),
    timeRange: "18:00 - 19:00",
    price: 7600,
    status: ReservationStatus.activa,
  ),
  Reservation(
    id: "2",
    sportEmoji: "🎾",
    sportLabel: "PADDLE",
    venueName: "Sede Castelar",
    courtCode: "Cancha 2",
    date: DateTime.now().add(const Duration(days: 3)),
    timeRange: "20:00 - 21:00",
    price: 6200,
    status: ReservationStatus.activa,
  ),
];

const mockVenues = <Venue>[
  Venue(
    id: "v1",
    name: "Sede Morón",
    address: "Rivadavia 19850",
    courtCount: 5,
    sports: ["Fútbol", "Paddle"],
  ),
  Venue(
    id: "v2",
    name: "Sede Ramos Mejía",
    address: "Av. de Mayo 450",
    courtCount: 3,
    sports: ["Básquet", "Vóley"],
  ),
  Venue(
    id: "v3",
    name: "Sede Castelar",
    address: "San Martín 120",
    courtCount: 4,
    sports: ["Fútbol", "Tenis"],
  ),
];
