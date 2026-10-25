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

  // Sends the recovery email. If the email is not registered we pretend it
  // worked, so nobody can use this screen to find out who has an account.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") return;
      throw _mapError(e);
    }
  }

  // Firebase only changes the password if the login is recent, so we sign in
  // again with the current password first (this also checks it is correct).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) throw const InvalidCredentialsException();

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // Translates Firebase error codes into our own exceptions.
  Exception _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case "too-many-requests":
        return const TooManyRequestsException();
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