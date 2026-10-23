import "../models/venue.dart";

// Single entry point for the venues data.
// Later the mock list is replaced by calls to the REST API.
class VenueService {
  // Temporary mock data.
  static const _mockVenues = <Venue>[
    Venue(
      id: "v1",
      name: "Sede Morón",
      address: "Rivadavia 19850",
      courtCount: 4,
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
    Venue(
      id: "v4",
      name: "Sede San Justo",
      address: "Av. Illia 3300",
      courtCount: 3,
      sports: ["Paddle", "Hockey"],
    ),
  ];

  // Later: GET /venues
  Future<List<Venue>> getVenues() async {
    // Fake network delay, so the loading spinner is visible.
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockVenues;
  }
}