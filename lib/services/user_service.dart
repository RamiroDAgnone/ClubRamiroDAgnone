import "../models/user.dart";

// Single entry point for everything related to the user's data.
// the Python REST API (which talks to PostgreSQL) and no screen will change.
class UserService {
  // Temporary mock data.
  User _currentUser = User(
    id: "1",
    firstName: "Ramiro",
    lastName: "D'Agnone",
    birthDate: DateTime(2001, 7, 28),
    email: "ramiro.dagnone@mail.com",
  );

  // Later: GET /users/me
  Future<User> getCurrentUser() async {
    return _currentUser;
  }

  // Later: PUT /users/me
  Future<User> updateUser(User updated) async {
    _currentUser = updated;
    return _currentUser;
  }
}