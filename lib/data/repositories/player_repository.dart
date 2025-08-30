import 'dart:io';
import 'package:fantasy_colegas_app/core/api_client.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';

class PlayerRepository {
  ApiClient _client(String token) => ApiClient(baseUrl: ApiConfig.baseUrl, token: token);

  Future<Player> createPlayer({
    required int leagueId,
    required String name,
    File? imageFile,
    required String token,
  }) async {
    final endpoint = 'leagues/$leagueId/players';
    
    final request = await _client(token).multipartRequest(endpoint, fields: {'name': name}, file: imageFile, fileFieldName: 'image');
    final response = await request.send();
    final responseBody = await _client(token).handleStreamedResponse(response);

    return Player.fromJson(responseBody);
  }

  Future<void> deletePlayer(int leagueId, int playerId, String token) async {
    await _client(token).delete('leagues/$leagueId/players/$playerId');
  }

  Future<Player> updatePlayer({
    required int leagueId,
    required int playerId,
    required String name,
    File? imageFile,
    required String token,
  }) async {
    final endpoint = 'leagues/$leagueId/players/$playerId';
    
    final request = await _client(token).multipartRequest(endpoint, method: 'PATCH', fields: {'name': name}, file: imageFile, fileFieldName: 'image');
    final response = await request.send();
    final responseBody = await _client(token).handleStreamedResponse(response);

    return Player.fromJson(responseBody);
  }
}