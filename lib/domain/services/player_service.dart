import 'dart:convert';
import 'dart:io';
import 'package:fantasy_colegas_app/domain/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';

class PlayerService {
  final AuthService _authService = AuthService();

  Future<Player?> createPlayer({
    required int leagueId,
    required String name,
    File? imageFile,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/leagues/$leagueId/players'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return Player.fromJson(json.decode(responseBody));
    } else {
      return null;
    }
  }

  Future<bool> deletePlayer(int leagueId, int playerId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no encontrado');

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/leagues/$leagueId/players/$playerId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }

  Future<Player?> updatePlayer({
    required int leagueId,
    required int playerId,
    required String name,
    File? imageFile,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no encontrado');

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('${ApiConfig.baseUrl}/leagues/$leagueId/players/$playerId'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return Player.fromJson(json.decode(responseBody));
    } else {
      return null;
    }
  }
}