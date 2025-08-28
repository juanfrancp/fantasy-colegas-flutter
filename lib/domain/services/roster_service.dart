import 'dart:convert';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:http/http.dart' as http;
import 'package:fantasy_colegas_app/domain/services/auth_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/data/models/roster_player.dart';

class RosterService {
  final AuthService _authService = AuthService();

  Future<List<RosterPlayer>> getUserRoster(int leagueId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Token no encontrado');
    }

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
      throw Exception('Error al cargar el equipo del usuario');
    }
  }

  Future<List<Player>> getAvailablePlayers(int leagueId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no encontrado');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/leagues/$leagueId/rosters/available-players'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Player.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar jugadores disponibles');
    }
  }

  Future<bool> replacePlayer({
    required int leagueId,
    required int playerToRemoveId,
    required int playerToAddId,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no encontrado');

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