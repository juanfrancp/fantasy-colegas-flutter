class League {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isPrivate;
  final String? joinCode;

  League({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.isPrivate,
    this.joinCode,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      isPrivate: json['isPrivate'] ?? false,
      joinCode: json['joinCode'],
    );
  }
}