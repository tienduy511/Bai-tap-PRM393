import 'dart:convert';

class User {
  final String name;
  final String email;

  User({required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
    );
  }

  @override
  String toString() => "User(name: $name, email: $email)";
}

class UserRepository {
  Future<List<User>> fetchUsers() async {
    await Future.delayed(Duration(milliseconds: 500));

    String jsonString = '''
    [
      {"name": "Alice", "email": "alice@mail.com"},
      {"name": "Bob", "email": "bob@mail.com"}
    ]
    ''';

    List decoded = jsonDecode(jsonString);
    return decoded.map((e) => User.fromJson(e)).toList();
  }
}

Future<void> runExercise2() async {
  final repo = UserRepository();
  final users = await repo.fetchUsers();

  print("Parsed Users:");
  users.forEach(print);
}