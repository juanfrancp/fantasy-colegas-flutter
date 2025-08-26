class UserStandings {
  final int userId;
  final String username;
  final String? profileImageUrl;
  final int totalPoints;

  UserStandings({
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.totalPoints,
  });

  factory UserStandings.fromJson(Map<String, dynamic> json) {
    return UserStandings(
      userId: json['userId'],
      username: json['username'],
      profileImageUrl: json['profileImageUrl'],
      totalPoints: json['totalPoints'],
    );
  }
}