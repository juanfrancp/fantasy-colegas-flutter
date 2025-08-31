import 'package:fantasy_colegas_app/data/models/match.dart';
import 'package:fantasy_colegas_app/data/models/match_create.dart';
import 'package:fantasy_colegas_app/data/repositories/match_repository.dart';

class MatchService {
  final MatchRepository _matchRepository = MatchRepository();

  Future<List<Match>> getUpcomingMatches() {
    return _matchRepository.getUpcomingMatches();
  }

  Future<List<Match>> getPastMatches() {
    return _matchRepository.getPastMatches();
  }

  Future<void> createMatch(MatchCreate match) {
    return _matchRepository.createMatch(match);
  }

  Future<Match> updateMatch(int matchId, MatchCreate matchData) {
    return _matchRepository.updateMatch(matchId, matchData);
  }
}