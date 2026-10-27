// The email is already registered.
class EmailAlreadyInUseException implements Exception {
  const EmailAlreadyInUseException();
}

// The password is too weak (Firebase requires at least 6 characters).
class WeakPasswordException implements Exception {
  const WeakPasswordException();
}

class InvalidEmailException implements Exception {
  const InvalidEmailException();
}

// The device has no internet connection.
class NetworkException implements Exception {
  const NetworkException();
}

// Wrong email or password.
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}

// Firebase blocked the requests for a while (too many attempts).
class TooManyRequestsException implements Exception {
  const TooManyRequestsException();
}

// The user closed the Google window without choosing an account.
class SignInCancelledException implements Exception {
  const SignInCancelledException();
}