class League {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final bool isPrivate;
  final String? joinCode;
  final int teamSize;
  final int participantsCount;

  League({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.isPrivate,
    this.joinCode,
    required this.teamSize,
    required this.participantsCount,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      isPrivate: json['isPrivate'] ?? false,
      joinCode: json['joinCode'],
      teamSize: json['teamSize'] ?? 0,
      participantsCount: json['numberOfPlayers'] ?? 0,
    );
  }
}