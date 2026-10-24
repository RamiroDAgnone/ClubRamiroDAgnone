import "package:firebase_auth/firebase_auth.dart";
import "auth_exceptions.dart";

// Single entry point for authentication. Wraps Firebase Auth.
class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Firebase signs the user in after creating the account, but CU-03
      // says the user goes back to the login. Later: before this sign out,
      // we will call POST /users to save the profile in PostgreSQL.
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
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