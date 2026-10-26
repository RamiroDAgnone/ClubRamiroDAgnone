import "../models/venue.dart";
import "api_client.dart";

// Single entry point for the venues data.
class VenueService {
  final _api = ApiClient();

  Future<List<Venue>> getVenues() async {
    final json = await _api.getList("/venues");
    return json.map((e) => Venue.fromJson(e as Map<String, dynamic>)).toList();
  }
}