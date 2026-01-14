import 'package:fantasy_colegas_app/data/models/match.dart';
import 'package:fantasy_colegas_app/data/models/match_create.dart';
import 'package:fantasy_colegas_app/core/api_client.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/data/models/player_match_stats_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchRepository {
  final String _baseUrl = ApiConfig.baseUrl;

  ApiClient _client(String token) => ApiClient(baseUrl: _baseUrl, token: token);

  Future<T> _executeWithAuth<T>(Future<T> Function(String token) action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception('User not authenticated');
    }
    return action(token);
  }

  Future<List<Match>> getUpcomingMatches() async {
    return _executeWithAuth((token) async {
      final List<dynamic> jsonList = await _client(token).get('matches/upcoming');
      return jsonList.map((json) => Match.fromJson(json)).toList();
    });
  }

  Future<List<Match>> getPastMatches() async {
    return _executeWithAuth((token) async {
      final List<dynamic> jsonList = await _client(token).get('matches/past');
      return jsonList.map((json) => Match.fromJson(json)).toList();
    });
  }

  Future<void> createMatch(MatchCreate match) async {
    return _executeWithAuth((token) async {
      await _client(token).post(
        'matches',
        body: match.toJson(),
      );
    });
  }

  Future<Match> updateMatch(int matchId, MatchCreate matchData) async {
    return _executeWithAuth((token) async {
      final jsonResponse = await _client(token).put(
        'matches/$matchId',
        body: matchData.toJson(),
      );
      return Match.fromJson(jsonResponse);
    });
  }

  Future<void> submitMatchStats(int matchId, int homeScore, int awayScore, List<PlayerMatchStatsUpdate> stats) async {
    return _executeWithAuth((token) async {
      await _client(token).post(
        'matches/$matchId/stats',
        body: { // Ahora enviamos un Mapa JSON con la estructura del DTO Java
          'homeScore': homeScore,
          'awayScore': awayScore,
          'playerStats': stats.map((e) => e.toJson()).toList(),
        },
      );
    });
  }

  Future<Match> getMatchById(int id) async {
    return _executeWithAuth((token) async {
      final response = await _client(token).get('matches/$id');
      return Match.fromJson(response);
    });
  }
}