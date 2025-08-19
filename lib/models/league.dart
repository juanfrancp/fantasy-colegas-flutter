class League {
  final int id;
  final String name;
  final String? description; // Puede ser nulo

  League({
    required this.id,
    required this.name,
    this.description,
  });

  // Un "factory constructor" para crear una Liga desde un JSON
  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}