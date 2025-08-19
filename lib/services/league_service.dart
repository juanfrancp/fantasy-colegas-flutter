import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/league.dart';
import '../models/user_score.dart';

class LeagueService {
  final String _baseUrl = 'http://10.0.2.2:8080/api/leagues';

  Future<List<League>> getMyLeagues() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    // Usamos el nuevo y mejorado endpoint
    final url = Uri.parse('$_baseUrl/my-leagues');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // El backend ahora devuelve una lista de ligas (un JSON array)
        final List<dynamic> leaguesJson = json.decode(response.body);

        // Convertimos cada item del JSON en un objeto League
        return leaguesJson.map((json) => League.fromJson(json)).toList();
      } else {
        // Si falla, imprimimos el error para depurar mejor
        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Fallo al cargar las ligas');
      }
    } catch (e) {
      print('Error de conexión en getMyLeagues: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<UserScore>> getScoreboard(int leagueId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) throw Exception('Token no encontrado');

    // Construimos la URL para el endpoint del scoreboard
    final url = Uri.parse('$_baseUrl/$leagueId/scoreboard');

    try {
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
        throw Exception('Fallo al cargar el marcador');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}