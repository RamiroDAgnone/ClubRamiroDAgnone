// The API answered 401: the token is missing, invalid or expired.
class ApiUnauthorizedException implements Exception {
  const ApiUnauthorizedException();
}

// The API answered 409: the resource already exists.
class ApiConflictException implements Exception {
  const ApiConflictException();
}

// Any other error answer from the API (400, 404, 422, 500...).
class ApiServerException implements Exception {
  final int statusCode;
  const ApiServerException(this.statusCode);
}