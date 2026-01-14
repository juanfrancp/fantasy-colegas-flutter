import 'package:fantasy_colegas_app/data/models/match.dart';
import 'package:fantasy_colegas_app/data/models/match_create.dart';
import 'package:fantasy_colegas_app/data/models/player_match_stats_update.dart';
import 'package:fantasy_colegas_app/data/repositories/match_repository.dart';

class MatchService {
  final MatchRepository _matchRepository = MatchRepository();

  Future<List<Match>> getUpcomingMatches(int leagueId) { // <--- Recibe ID
    return _matchRepository.getUpcomingMatches(leagueId);
  }

  Future<List<Match>> getPastMatches(int leagueId) { // <--- Recibe ID
    return _matchRepository.getPastMatches(leagueId);
  }

  Future<void> createMatch(MatchCreate match) {
    return _matchRepository.createMatch(match);
  }

  Future<Match> updateMatch(int matchId, MatchCreate matchData) {
    return _matchRepository.updateMatch(matchId, matchData);
  }

  Future<void> submitMatchStats(int matchId, int homeScore, int awayScore, List<PlayerMatchStatsUpdate> stats) {
    return _matchRepository.submitMatchStats(matchId, homeScore, awayScore, stats);
  }

  Future<Match> getMatch(int id) {
    return _matchRepository.getMatchById(id);
  }
}