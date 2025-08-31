// lib/data/repositories/roster_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/data/models/roster_player.dart';

class RosterRepository {
  Future<List<RosterPlayer>> fetchUserRoster(int leagueId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/leagues/$leagueId/rosters'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => RosterPlayer.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar el equipo del usuario desde el repositorio');
    }
  }

  Future<List<Player>> fetchAvailablePlayers(int leagueId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/leagues/$leagueId/rosters/available-players'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Player.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar jugadores disponibles desde el repositorio');
    }
  }

  Future<bool> replacePlayer({
    required int leagueId,
    required int playerToRemoveId,
    required int playerToAddId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/leagues/$leagueId/rosters/replace'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'playerToRemoveId': playerToRemoveId,
        'playerToAddId': playerToAddId,
      }),
    );

    return response.statusCode == 200;
  }
}