import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/data/models/roster_player.dart';
import 'package:fantasy_colegas_app/data/repositories/roster_repository.dart';
import 'package:fantasy_colegas_app/domain/services/auth_service.dart';

class RosterService {
  final AuthService _authService = AuthService();
  final RosterRepository _rosterRepository = RosterRepository();

  Future<List<RosterPlayer>> getUserRoster(int leagueId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Token no encontrado');
    }
    return _rosterRepository.fetchUserRoster(leagueId, token);
  }

  Future<List<Player>> getAvailablePlayers(int leagueId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no encontrado');

    return _rosterRepository.fetchAvailablePlayers(leagueId, token);
  }

  Future<bool> replacePlayer({
    required int leagueId,
    required int playerToRemoveId,
    required int playerToAddId,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no encontrado');

    return _rosterRepository.replacePlayer(
      leagueId: leagueId,
      playerToRemoveId: playerToRemoveId,
      playerToAddId: playerToAddId,
      token: token,
    );
  }
}