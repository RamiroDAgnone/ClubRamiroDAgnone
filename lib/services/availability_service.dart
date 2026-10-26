import "../models/time_slot.dart";
import "api_client.dart";

// Single entry point for the availability of a sport space.
// The backend calculates it: opening hours, future only, no overlaps.
class AvailabilityService {
  final _api = ApiClient();

  Future<List<TimeSlot>> getSlots({
    required String spaceId,
    required DateTime date,
    required int durationHours,
  }) async {
    final day = date.toIso8601String().split("T").first;
    final json = await _api.getList(
      "/sport-spaces/$spaceId/availability?date=$day&duration=$durationHours",
    );
    return json
        .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}