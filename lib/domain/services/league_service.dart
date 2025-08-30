import 'dart:developer';
import 'dart:io';
import 'package:fantasy_colegas_app/core/api_client.dart';
import 'package:fantasy_colegas_app/data/models/join_request.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';
import 'package:fantasy_colegas_app/data/models/user_standings.dart';
import 'package:fantasy_colegas_app/data/repositories/league_repository.dart';
import 'auth_service.dart';

class LeagueService {
  final LeagueRepository _leagueRepository = LeagueRepository();
  final AuthService _authService = AuthService();

  Future<T> _executeWithAuth<T>(Future<T> Function(String token) action) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Sesión inválida. Por favor, inicia sesión de nuevo.');
    }
    try {
      return await action(token);
    } on ApiException catch (e) {
      log('Error de API en LeagueService: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      log('Error inesperado en LeagueService: $e');
      throw Exception('Ocurrió un error inesperado.');
    }
  }


  Future<List<League>> getMyLeagues() =>
      _executeWithAuth((token) => _leagueRepository.getMyLeagues(token));

  Future<List<League>> getPublicLeagues() =>
      _executeWithAuth((token) => _leagueRepository.getPublicLeagues(token));

  Future<List<League>> searchLeaguesByName(String name) =>
      _executeWithAuth((token) => _leagueRepository.searchLeaguesByName(name, token));
      
  Future<League> findLeagueByCode(String code) =>
      _executeWithAuth((token) => _leagueRepository.findLeagueByCode(code, token));

  Future<League> getLeagueById(int leagueId) =>
      _executeWithAuth((token) => _leagueRepository.getLeagueById(leagueId, token));

  Future<List<UserStandings>> getLeagueStandings(int leagueId) =>
      _executeWithAuth((token) => _leagueRepository.getLeagueStandings(leagueId, token));

  Future<List<Player>> getLeaguePlayers(int leagueId) =>
      _executeWithAuth((token) => _leagueRepository.getLeaguePlayers(leagueId, token));
      
  Future<List<User>> getLeagueMembers(int leagueId) =>
      _executeWithAuth((token) => _leagueRepository.getLeagueMembers(leagueId, token));

  Future<List<JoinRequest>> getPendingJoinRequests(int leagueId) =>
      _executeWithAuth((token) => _leagueRepository.getPendingJoinRequests(leagueId, token));

  Future<List<int>> getMyPendingRequestLeagueIds() =>
      _executeWithAuth((token) => _leagueRepository.getMyPendingRequestLeagueIds(token));

  Future<League> createLeague({
    required String name,
    String? description,
    required int teamSize,
    required bool isPrivate,
  }) {
    final leagueData = {
      'name': name, 'description': description, 'teamSize': teamSize, 'isPrivate': isPrivate,
    };
    return _executeWithAuth((token) => _leagueRepository.createLeague(leagueData, token));
  }

  Future<League> updateLeague({
    required int leagueId,
    required String name,
    String? description,
    required bool isPrivate,
    required int teamSize,
    String? imageUrl,
  }) {
    final leagueData = {
      'name': name, 'description': description, 'isPrivate': isPrivate, 'teamSize': teamSize, 'image': imageUrl,
    };
    return _executeWithAuth((token) => _leagueRepository.updateLeague(leagueId, leagueData, token));
  }
  
  Future<League> updateLeagueTeamSize({required int leagueId, required int newTeamSize}) =>
      _executeWithAuth((token) => _leagueRepository.updateLeagueTeamSize(leagueId, newTeamSize, token));

  Future<String> uploadLeagueImage({required String leagueId, required File imageFile}) =>
      _executeWithAuth((token) => _leagueRepository.uploadLeagueImage(leagueId, imageFile, token));

  Future<void> joinPublicLeague(String joinCode) =>
      _executeWithAuth((token) => _leagueRepository.joinPublicLeague(joinCode, token));

  Future<void> requestToJoinPrivateLeague(int leagueId) =>
      _executeWithAuth((token) => _leagueRepository.requestToJoinPrivateLeague(leagueId, token));

  Future<void> cancelJoinRequest(int leagueId) =>
      _executeWithAuth((token) => _leagueRepository.cancelJoinRequest(leagueId, token));

  Future<void> acceptJoinRequest(int leagueId, int requestId) =>
      _executeWithAuth((token) => _leagueRepository.acceptJoinRequest(leagueId, requestId, token));

  Future<void> rejectJoinRequest(int leagueId, int requestId) =>
      _executeWithAuth((token) => _leagueRepository.rejectJoinRequest(leagueId, requestId, token));
      
  Future<void> makeUserAdmin(int leagueId, int targetUserId) =>
      _executeWithAuth((token) => _leagueRepository.changeUserRole(leagueId, targetUserId, 'ADMIN', token));

  Future<void> leaveLeague(int leagueId) =>
      _executeWithAuth((token) => _leagueRepository.leaveLeague(leagueId, token));

  Future<void> deleteLeague(int leagueId) =>
      _executeWithAuth((token) => _leagueRepository.deleteLeague(leagueId, token));

  Future<void> expelUser(int leagueId, int targetUserId) =>
      _executeWithAuth((token) => _leagueRepository.expelUser(leagueId, targetUserId, token));
}