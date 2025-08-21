import 'dart:convert';
import '../models/user_score.dart';
import 'package:http/http.dart' as http;
import '../models/league.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';


class LeagueRepository {
  final String _baseUrl = '${ApiConfig.baseUrl}/leagues';

  Future<List<League>> getMyLeagues(String token) async {
    final url = Uri.parse('$_baseUrl/my-leagues');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> leaguesJson = json.decode(response.body);
      return leaguesJson.map((json) => League.fromJson(json)).toList();
    } else {
      // Lanzamos una excepción que el servicio podrá capturar
      throw Exception('Failed to load leagues from repository');
    }
  }

  Future<List<UserScore>> getScoreboard(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/scoreboard');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> scoreboardJson = json.decode(response.body);
      return scoreboardJson.map((json) => UserScore.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load scoreboard from repository');
    }
  }

  Future<List<League>> getPublicLeagues(String token) async {
    final url = Uri.parse('$_baseUrl/public');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => League.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load public leagues');
    }
  }

  Future<List<League>> searchLeaguesByName(String name, String token) async {
    final url = Uri.parse('$_baseUrl/search/name?name=$name');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => League.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search leagues by name');
    }
  }

  Future<League> findLeagueByCode(String code, String token) async {
    final url = Uri.parse('$_baseUrl/search/code?code=$code');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return League.fromJson(json.decode(response.body));
    } else {
      throw Exception('League not found with this code');
    }
  }

  Future<void> joinPublicLeague(String joinCode, String token) async {
    final url = Uri.parse('$_baseUrl/join-by-code');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'joinCode': joinCode}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to join public league');
    }
  }

  Future<void> requestToJoinPrivateLeague(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/request-join');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send join request to private league');
    }
  }

  Future<List<int>> getMyPendingRequestLeagueIds(String token) async {
    final url = Uri.parse('$_baseUrl/my-pending-requests');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<int>().toList();
    } else {
      throw Exception('Failed to load pending requests');
    }
  }

  Future<void> cancelJoinRequest(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/request-join');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to cancel join request');
    }
  }
}