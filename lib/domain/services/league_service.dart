import 'dart:developer';
import '../../data/models/league.dart';
import '../../data/models/user_score.dart';
import '/data/repositories/league_repository.dart';
import 'auth_service.dart';


class LeagueService {
  final LeagueRepository _leagueRepository = LeagueRepository();
  final AuthService _authService = AuthService();

  Future<List<League>> getMyLeagues() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token not found. Invalid session.');
      }
      return await _leagueRepository.getMyLeagues(token);
    } catch (e) {
      log('Error in getMyLeagues (service): $e');
      throw Exception('Failed to load leagues');
    }
  }

  Future<List<UserScore>> getScoreboard(int leagueId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token not found. Invalid session.');
      }
      return await _leagueRepository.getScoreboard(leagueId, token);
    } catch (e) {
      log('Error in getScoreboard (service): $e');
      throw Exception('Failed to load scoreboard');
    }
  }

  Future<List<League>> getPublicLeagues() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');
    return await _leagueRepository.getPublicLeagues(token);
  }

  Future<List<League>> searchLeaguesByName(String name) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');
    return await _leagueRepository.searchLeaguesByName(name, token);
  }

  Future<League> findLeagueByCode(String code) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');
    return await _leagueRepository.findLeagueByCode(code, token);
  }

  Future<void> joinPublicLeague(String joinCode) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');
    await _leagueRepository.joinPublicLeague(joinCode, token);
  }

  Future<void> requestToJoinPrivateLeague(int leagueId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');
    await _leagueRepository.requestToJoinPrivateLeague(leagueId, token);
  }

  Future<List<int>> getMyPendingRequestLeagueIds() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');
    return await _leagueRepository.getMyPendingRequestLeagueIds(token);
  }

  Future<void> cancelJoinRequest(int leagueId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');
    await _leagueRepository.cancelJoinRequest(leagueId, token);
  }
}