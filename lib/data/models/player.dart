class Player {
  final int id;
  final String name;
  final String? image;
  final int totalPoints;

  Player({
    required this.id,
    required this.name,
    this.image,
    required this.totalPoints,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      totalPoints: json['totalPoints'],
    );
  }
}