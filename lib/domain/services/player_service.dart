import 'dart:developer';
import 'dart:io';
import 'package:fantasy_colegas_app/core/api_client.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/data/repositories/player_repository.dart';
import 'auth_service.dart';

class PlayerService {
  final AuthService _authService = AuthService();
  final PlayerRepository _playerRepository = PlayerRepository();

  Future<T> _executeWithAuth<T>(Future<T> Function(String token) action) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Sesión inválida. Por favor, inicia sesión de nuevo.');
    }
    try {
      return await action(token);
    } on ApiException catch (e) {
      log('Error de API en PlayerService: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      log('Error inesperado en PlayerService: $e');
      throw Exception('Ocurrió un error inesperado.');
    }
  }

  Future<Player> createPlayer({
    required int leagueId,
    required String name,
    File? imageFile,
  }) =>
      _executeWithAuth((token) => _playerRepository.createPlayer(
            leagueId: leagueId,
            name: name,
            imageFile: imageFile,
            token: token,
          ));

  Future<void> deletePlayer(int leagueId, int playerId) =>
      _executeWithAuth((token) => _playerRepository.deletePlayer(leagueId, playerId, token));

  Future<Player> updatePlayer({
    required int leagueId,
    required int playerId,
    required String name,
    File? imageFile,
  }) =>
      _executeWithAuth((token) => _playerRepository.updatePlayer(
            leagueId: leagueId,
            playerId: playerId,
            name: name,
            imageFile: imageFile,
            token: token,
          ));
}