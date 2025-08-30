import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/data/models/join_request.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';
import 'package:http/http.dart' as http;

import '../../data/models/league.dart';
import '../../data/models/user_standings.dart';
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

  Future<List<UserStandings>> getScoreboard(int leagueId) async {
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

  Future<League?> createLeague({
    required String name,
    String? description,
    required int teamSize,
    required bool isPrivate,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token not found. Invalid session.');
      }
      final league = await _leagueRepository.createLeague(name, description, teamSize, isPrivate, token);
      return league;
    } catch (e) {
      log('Error creating league (service): $e');
      return null;
    }
  }

  Future<String?> uploadLeagueImage({
    required String leagueId,
    required File imageFile,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token not found. Invalid session.');
      }
      return await _leagueRepository.uploadLeagueImage(leagueId, imageFile, token);
    } catch (e) {
      log('Error uploading league image (service): $e');
      return null;
    }
  }

  Future<int> getPendingJoinRequestsCount(int leagueId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }
      return await _leagueRepository.getPendingJoinRequestsCount(leagueId, token);
    } catch (e) {
      return 0;
    }
  }

  Future<List<User>> getLeagueMembers(int leagueId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }
    return await _leagueRepository.getLeagueMembers(leagueId, token);
  }

  Future<List<JoinRequest>> getPendingJoinRequests(int leagueId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');
    return _leagueRepository.getPendingJoinRequests(leagueId, token);
  }

  Future<void> acceptJoinRequest(int leagueId, int requestId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');
    await _leagueRepository.acceptJoinRequest(leagueId, requestId, token);
  }

  Future<void> rejectJoinRequest(int leagueId, int requestId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');
    await _leagueRepository.rejectJoinRequest(leagueId, requestId, token);
  }

  Future<League?> updateLeague(int leagueId, String name, String? description, bool isPrivate, int teamSize, String? imageUrl) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token not found');

      final leagueData = {
        'name': name,
        'description': description,
        'isPrivate': isPrivate,
        'teamSize': teamSize,
        'image': imageUrl,
      };

      final updatedLeagueJson = await _leagueRepository.updateLeague(leagueId, leagueData, token);
      return League.fromJson(updatedLeagueJson);
    } catch (e) {
      log('Error updating league: $e');
      return null;
    }
  }

  Future<League?> getLeagueById(int leagueId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token not found');
      final leagueJson = await _leagueRepository.getLeagueById(leagueId, token);
      return League.fromJson(leagueJson);
    } catch (e) {
      log('Error getting league by id: $e');
      return null;
    }
  }

  Future<String?> leaveLeague(int leagueId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token not found');
      await _leagueRepository.leaveLeague(leagueId, token);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<bool> deleteLeague(int leagueId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token not found');
      await _leagueRepository.deleteLeague(leagueId, token);
      return true;
    } catch (e) {
      log('Error deleting league: $e');
      return false;
    }
  }

  Future<String?> expelUser(int leagueId, int targetUserId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token not found');
      await _leagueRepository.expelUser(leagueId, targetUserId, token);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> makeUserAdmin(int leagueId, int targetUserId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token not found');
      await _leagueRepository.changeUserRole(leagueId, targetUserId, 'ADMIN', token);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<List<Player>> getLeaguePlayers(int leagueId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/players/league/$leagueId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Player.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los jugadores de la liga');
    }
  }

    Future<List<UserStandings>> getLeagueStandings(int leagueId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no encontrado');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/leagues/$leagueId/standings'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => UserStandings.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar la clasificación');
    }
  }

  Future<League?> updateLeagueTeamSize({
    required int leagueId,
    required int newTeamSize,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no encontrado');

    final response = await http.patch( // Usamos PATCH para actualizaciones parciales
      Uri.parse('${ApiConfig.baseUrl}/leagues/$leagueId/team-size'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'teamSize': newTeamSize}),
    );

    if (response.statusCode == 200) {
      return League.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      print('Error al actualizar tamaño del equipo: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }
}