class UserScore {
  final int userId;
  final String username;
  final double totalPoints;

  UserScore({
    required this.userId,
    required this.username,
    required this.totalPoints,
  });

  factory UserScore.fromJson(Map<String, dynamic> json) {
    return UserScore(
      userId: json['userId'],
      username: json['username'],
      totalPoints: (json['totalPoints'] as num).toDouble(),
    );
  }
}