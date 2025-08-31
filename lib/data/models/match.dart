import 'package:fantasy_colegas_app/data/models/player.dart';

class MatchTeam {
  final int id;
  final String name;
  final List<Player> players;

  MatchTeam({required this.id, required this.name, required this.players});

  factory MatchTeam.fromJson(Map<String, dynamic> json) {
    var playerList = json['players'] as List;
    List<Player> players = playerList.map((i) => Player.fromJson(i)).toList();
    return MatchTeam(
      id: json['id'],
      name: json['name'],
      players: players,
    );
  }
}

class Match {
  final int id;
  final MatchTeam homeTeam;
  final MatchTeam awayTeam;
  final int? homeScore;
  final int? awayScore;
  final DateTime matchDate;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    required this.matchDate,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      homeTeam: MatchTeam.fromJson(json['homeTeam']),
      awayTeam: MatchTeam.fromJson(json['awayTeam']),
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      matchDate: DateTime.parse(json['matchDate']),
    );
  }
}