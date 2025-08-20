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
}