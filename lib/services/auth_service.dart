import "package:firebase_auth/firebase_auth.dart";
import "auth_exceptions.dart";
import "api_client.dart";

// Single entry point for authentication. Wraps Firebase Auth.
class AuthService {
  final _auth = FirebaseAuth.instance;
  final _api = ApiClient();

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }

    // Firebase signed the user in, so ApiClient already has a token to use.
    try {
      await _api.post("/users", {
        "first_name": firstName,
        "last_name": lastName,
        "birth_date": birthDate.toIso8601String().split("T").first,
      });
    } catch (_) {
      // No profile in Postgres: undo the Firebase account so the user can
      // register again with the same email. Ignore a failure of the undo.
      try {
        await _auth.currentUser?.delete();
      } catch (_) {}
      rethrow;
    }

    // User goes back to the login.
    await _auth.signOut();
  }
  
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // Translates Firebase error codes into our own exceptions.
  Exception _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case "email-already-in-use":
        return const EmailAlreadyInUseException();
      case "weak-password":
        return const WeakPasswordException();
      case "invalid-email":
        return const InvalidEmailException();
      case "network-request-failed":
        return const NetworkException();
      case "invalid-credential":
      case "wrong-password":
      case "user-not-found":
        return const InvalidCredentialsException();
      default:
        return e;
    }
  }
}