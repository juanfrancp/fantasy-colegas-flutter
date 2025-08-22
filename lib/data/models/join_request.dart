import 'package:fantasy_colegas_app/data/models/user.dart';

class JoinRequest {
  final int id;
  final User user;

  JoinRequest({
    required this.id,
    required this.user,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      id: json['id'],
      user: User(
        id: json['userId'],
        username: json['username'],
        profileImageUrl: json['profileImageUrl'],
      ),
    );
  }
}