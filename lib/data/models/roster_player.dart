class RosterPlayer {
  final int playerId;
  final String name;
  final String role;
  final String? image;
  final int totalPoints;

  RosterPlayer({
    required this.playerId,
    required this.name,
    required this.role,
    this.image,
    required this.totalPoints,
  });

  factory RosterPlayer.fromJson(Map<String, dynamic> json) {
    return RosterPlayer(
      playerId: json['playerId'],
      name: json['playerName'],
      role: json['role'],
      image: json['playerImage'],
      totalPoints: json['totalPoints'],
    );
  }
}