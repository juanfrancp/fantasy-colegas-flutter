class League {
  final int id;
  final String name;
  final String? description;

  League({
    required this.id,
    required this.name,
    this.description,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
