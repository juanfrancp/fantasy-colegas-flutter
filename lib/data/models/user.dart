class User {
  final int id;
  final String username;
  final String? email;
  final String? profileImageUrl;
  final String role;

  User({
    required this.id,
    required this.username,
    this.email,
    this.profileImageUrl,
    this.role = 'USER',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      role: json['appRole'] ?? 'USER',
    );
  }
}