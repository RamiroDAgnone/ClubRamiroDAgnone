// The time range is already taken (HTTP 409 in the real API).
class SlotNotAvailableException implements Exception {
  const SlotNotAvailableException();
}

// The booking data breaks a business rule (HTTP 400 in the real API).
class InvalidBookingException implements Exception {
  final String message;
  const InvalidBookingException(this.message);
}