import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Importamos el servicio de autenticación
import '../models/league.dart';
import '../models/user_score.dart';

class LeagueService {
  final String _baseUrl = 'http://10.0.2.2:8080/api/leagues';
  final AuthService _authService = AuthService(); // Obtenemos la instancia del servicio

  Future<List<League>> getMyLeagues() async {
    // MODIFICADO: Obtenemos el token desde el AuthService
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Token no encontrado. Sesión no válida.');
    }

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
        final List<dynamic> leaguesJson = json.decode(response.body);
        return leaguesJson.map((json) => League.fromJson(json)).toList();
      } else {
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
    // MODIFICADO: Obtenemos el token desde el AuthService
    final token = await _authService.getToken();

    if (token == null) throw Exception('Token no encontrado. Sesión no válida.');

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
