import 'dart:io';

import 'package:fantasy_colegas_app/core/api_client.dart';

import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/data/models/join_request.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';
import 'package:fantasy_colegas_app/data/models/user_standings.dart';

class LeagueRepository {
  final String _baseUrl = '${ApiConfig.baseUrl}/leagues';

  ApiClient _client(String token) => ApiClient(baseUrl: _baseUrl, token: token);

  Future<List<League>> getMyLeagues(String token) async {
    final List<dynamic> jsonList = await _client(token).get('my-leagues');
    return jsonList.map((json) => League.fromJson(json)).toList();
  }

  Future<List<League>> getPublicLeagues(String token) async {
    final List<dynamic> jsonList = await _client(token).get('public');
    return jsonList.map((json) => League.fromJson(json)).toList();
  }
  
  Future<List<League>> searchLeaguesByName(String name, String token) async {
    final List<dynamic> jsonList = await _client(token).get('search/name?name=$name');
    return jsonList.map((json) => League.fromJson(json)).toList();
  }

  Future<League> findLeagueByCode(String code, String token) async {
    final jsonResponse = await _client(token).get('search/code?code=$code');
    return League.fromJson(jsonResponse);
  }
  
  Future<List<UserStandings>> getLeagueStandings(int leagueId, String token) async {
    final List<dynamic> jsonList = await _client(token).get('$leagueId/standings');
    return jsonList.map((json) => UserStandings.fromJson(json)).toList();
  }

  Future<League> getLeagueById(int leagueId, String token) async {
    final jsonResponse = await _client(token).get('$leagueId');
    return League.fromJson(jsonResponse);
  }

  Future<List<Player>> getLeaguePlayers(int leagueId, String token) async {
    final List<dynamic> jsonList = await ApiClient(baseUrl: ApiConfig.baseUrl, token: token).get('players/league/$leagueId');
    return jsonList.map((json) => Player.fromJson(json)).toList();
  }
  
  Future<List<User>> getLeagueMembers(int leagueId, String token) async {
    final List<dynamic> jsonList = await _client(token).get('$leagueId/members');
    return jsonList.map((json) => User.fromJson(json)).toList();
  }

  Future<List<JoinRequest>> getPendingJoinRequests(int leagueId, String token) async {
    final List<dynamic> jsonList = await _client(token).get('$leagueId/requests');
    return jsonList.map((json) => JoinRequest.fromJson(json)).toList();
  }

  Future<List<int>> getMyPendingRequestLeagueIds(String token) async {
    final List<dynamic> jsonList = await _client(token).get('my-pending-requests');
    return jsonList.cast<int>().toList();
  }

  Future<League> createLeague(Map<String, dynamic> leagueData, String token) async {
    final jsonResponse = await _client(token).post('', body: leagueData);
    return League.fromJson(jsonResponse);
  }

  Future<League> updateLeague(int leagueId, Map<String, dynamic> leagueData, String token) async {
    final jsonResponse = await _client(token).put('$leagueId', body: leagueData);
    return League.fromJson(jsonResponse);
  }

  Future<League> updateLeagueTeamSize(int leagueId, int newTeamSize, String token) async {
    final jsonResponse = await _client(token).patch(
      '$leagueId/team-size',
      body: {'teamSize': newTeamSize},
    );
    return League.fromJson(jsonResponse);
  }

  Future<String> uploadLeagueImage(String leagueId, File imageFile, String token) async {
    final jsonResponse = await ApiClient(baseUrl: ApiConfig.baseUrl, token: token)
        .multipartPost('leagues/$leagueId/upload-image', imageFile, 'image');
    return jsonResponse['imageUrl'];
}

  Future<void> joinPublicLeague(String joinCode, String token) async {
    await _client(token).post('join-by-code', body: {'joinCode': joinCode});
  }

  Future<void> requestToJoinPrivateLeague(int leagueId, String token) async {
    await _client(token).post('$leagueId/request-join');
  }

  Future<void> acceptJoinRequest(int leagueId, int requestId, String token) async {
    await _client(token).post('$leagueId/requests/$requestId/accept');
  }

  Future<void> rejectJoinRequest(int leagueId, int requestId, String token) async {
    await _client(token).post('$leagueId/requests/$requestId/reject');
  }

  Future<void> changeUserRole(int leagueId, int targetUserId, String newRole, String token) async {
    await _client(token).patch(
      '$leagueId/participants/$targetUserId/role',
      body: {'newRole': newRole},
    );
  }

  Future<void> leaveLeague(int leagueId, String token) async {
    await _client(token).delete('$leagueId/leave');
  }

  Future<void> deleteLeague(int leagueId, String token) async {
    await _client(token).delete('$leagueId');
  }

  Future<void> expelUser(int leagueId, int targetUserId, String token) async {
    await _client(token).delete('$leagueId/expel/$targetUserId');
  }

  Future<void> cancelJoinRequest(int leagueId, String token) async {
    // Asumiendo que el endpoint es el mismo para POST (enviar) y DELETE (cancelar)
    await _client(token).delete('$leagueId/request-join');
  }
}