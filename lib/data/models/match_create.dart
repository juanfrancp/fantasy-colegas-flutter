class MatchCreate {
  final String leagueId;
  final String homeTeamName;
  final String awayTeamName;
  final DateTime matchDate;
  final List<int> homeTeamPlayerIds;
  final List<int> awayTeamPlayerIds;

  MatchCreate({
    required this.leagueId,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.matchDate,
    required this.homeTeamPlayerIds,
    required this.awayTeamPlayerIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'leagueId': leagueId,
      'homeTeamName': homeTeamName,
      'awayTeamName': awayTeamName,
      'matchDate': matchDate.toIso8601String(),
      'homeTeamPlayerIds': homeTeamPlayerIds,
      'awayTeamPlayerIds': awayTeamPlayerIds,
    };
  }
}