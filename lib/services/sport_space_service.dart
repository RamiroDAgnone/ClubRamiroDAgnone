import "../models/sport_space.dart";

// Single entry point for the sport spaces (courts) data.
class SportSpaceService {
  // Temporary mock data, same as backend/app/seed.py.
  static const _mockSpaces = <SportSpace>[
    // Sede Morón (v1)
    SportSpace(id: "s1", venueId: "v1", sport: "Fútbol", variant: "F5", number: 1,
        name: "Moron_Rivadavia_19850_Futbol_F5_1", pricePerHour: 7600),
    SportSpace(id: "s2", venueId: "v1", sport: "Fútbol", variant: "F5", number: 2,
        name: "Moron_Rivadavia_19850_Futbol_F5_2", pricePerHour: 7600),
    SportSpace(id: "s3", venueId: "v1", sport: "Paddle", variant: null, number: 1,
        name: "Moron_Rivadavia_19850_Paddle_1", pricePerHour: 6200),
    SportSpace(id: "s4", venueId: "v1", sport: "Paddle", variant: null, number: 2,
        name: "Moron_Rivadavia_19850_Paddle_2", pricePerHour: 6200),
    // Sede Ramos Mejía (v2)
    SportSpace(id: "s5", venueId: "v2", sport: "Básquet", variant: null, number: 1,
        name: "Ramos_Mejia_Av_de_Mayo_450_Basquet_1", pricePerHour: 5800),
    SportSpace(id: "s6", venueId: "v2", sport: "Vóley", variant: null, number: 1,
        name: "Ramos_Mejia_Av_de_Mayo_450_Voley_1", pricePerHour: 5200),
    SportSpace(id: "s7", venueId: "v2", sport: "Vóley", variant: null, number: 2,
        name: "Ramos_Mejia_Av_de_Mayo_450_Voley_2", pricePerHour: 5200),
    // Sede Castelar (v3)
    SportSpace(id: "s8", venueId: "v3", sport: "Fútbol", variant: "F5", number: 1,
        name: "Castelar_San_Martin_120_Futbol_F5_1", pricePerHour: 7600),
    SportSpace(id: "s9", venueId: "v3", sport: "Fútbol", variant: "F11", number: 1,
        name: "Castelar_San_Martin_120_Futbol_F11_1", pricePerHour: 15000),
    SportSpace(id: "s10", venueId: "v3", sport: "Tenis", variant: null, number: 1,
        name: "Castelar_San_Martin_120_Tenis_1", pricePerHour: 5500),
    SportSpace(id: "s11", venueId: "v3", sport: "Tenis", variant: null, number: 2,
        name: "Castelar_San_Martin_120_Tenis_2", pricePerHour: 5500),
    // Sede San Justo (v4)
    SportSpace(id: "s12", venueId: "v4", sport: "Paddle", variant: null, number: 1,
        name: "San_Justo_Av_Illia_3300_Paddle_1", pricePerHour: 6200),
    SportSpace(id: "s13", venueId: "v4", sport: "Paddle", variant: null, number: 2,
        name: "San_Justo_Av_Illia_3300_Paddle_2", pricePerHour: 6200),
    SportSpace(id: "s14", venueId: "v4", sport: "Hockey", variant: null, number: 1,
        name: "San_Justo_Av_Illia_3300_Hockey_1", pricePerHour: 9000),
  ];

  // Later: GET /venues/{venueId}/spaces
  Future<List<SportSpace>> getSpacesByVenue(String venueId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockSpaces.where((s) => s.venueId == venueId).toList();
  }
}