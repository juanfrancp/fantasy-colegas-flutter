import 'dart:developer';
import 'dart:io';
import 'package:fantasy_colegas_app/data/models/join_request.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';

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

  Future<bool> uploadLeagueImage({
    required String leagueId,
    required File imageFile,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token not found. Invalid session.');
      }
      await _leagueRepository.uploadLeagueImage(leagueId, imageFile, token);
      return true;
    } catch (e) {
      log('Error uploading league image (service): $e');
      return false;
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
}