import 'package:fantasy_colegas_app/data/models/user.dart';

class League {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final bool isPrivate;
  final String? joinCode;
  final int teamSize;
  final int participantsCount;
  final List<User> admins;

  League({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.isPrivate,
    this.joinCode,
    required this.teamSize,
    required this.participantsCount,
    this.admins = const [],
  });

  factory League.fromJson(Map<String, dynamic> json) {

    var adminList = <User>[];
    if (json['admins'] != null) {
      adminList = (json['admins'] as List)
          .map((adminJson) => User.fromJson(adminJson))
          .toList();
    }

    return League(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      isPrivate: json['isPrivate'] ?? false,
      joinCode: json['joinCode'],
      teamSize: json['teamSize'] ?? 0,
      participantsCount: json['numberOfPlayers'] ?? 0,
      admins: adminList,
    );
  }
}