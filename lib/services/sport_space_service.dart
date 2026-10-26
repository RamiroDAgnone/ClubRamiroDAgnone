import "../models/sport_space.dart";
import "api_client.dart";

// Single entry point for the sport spaces (courts) data.
class SportSpaceService {
  final _api = ApiClient();

  Future<List<SportSpace>> getSpacesByVenue(String venueId) async {
    final json = await _api.getList("/venues/$venueId/spaces");
    return json
        .map((e) => SportSpace.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}