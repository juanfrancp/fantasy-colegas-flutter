class User {
  final int id;
  final String username;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.username,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}