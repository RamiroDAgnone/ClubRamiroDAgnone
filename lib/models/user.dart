class User {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String email;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
  });

  // Computed property: it is not stored, it is calculated when read.
  String get fullName => "$firstName $lastName";

  // Builds a User from the JSON map that the API will send us.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] as String,
      firstName: json["first_name"] as String,
      lastName: json["last_name"] as String,
      birthDate: DateTime.parse(json["birth_date"] as String),
      email: json["email"] as String,
    );
  }

  // Converts a User back into a JSON map to send it to the API.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "first_name": firstName,
      "last_name": lastName,
      "birth_date": birthDate.toIso8601String(),
      "email": email,
    };
  }
}