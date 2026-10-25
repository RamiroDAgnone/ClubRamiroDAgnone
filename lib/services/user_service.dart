import "../models/user.dart";
import "api_client.dart";

// Single entry point for everything related to the user's data.
class UserService {
  final _api = ApiClient();

  Future<User> getCurrentUser() async {
    final json = await _api.get("/users/me");
    return User.fromJson(json);
  }

  // Only these 3 fields can be edited: email and role are ignored by the API.
  Future<User> updateUser(User updated) async {
    final json = await _api.put("/users/me", {
      "first_name": updated.firstName,
      "last_name": updated.lastName,
      "birth_date": updated.toJson()["birth_date"],
    });
    return User.fromJson(json);
  }
}