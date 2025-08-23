import 'dart:convert';
import 'dart:io';
import 'package:fantasy_colegas_app/data/models/join_request.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';

import '../models/user_score.dart';
import 'package:http/http.dart' as http;
import '../models/league.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';


class LeagueRepository {
  final String _baseUrl = '${ApiConfig.baseUrl}/leagues';

  Future<List<League>> getMyLeagues(String token) async {
    final url = Uri.parse('$_baseUrl/my-leagues');
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
      throw Exception('Failed to load leagues from repository');
    }
  }

  Future<List<UserScore>> getScoreboard(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/scoreboard');
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
      throw Exception('Failed to load scoreboard from repository');
    }
  }

  Future<List<League>> getPublicLeagues(String token) async {
    final url = Uri.parse('$_baseUrl/public');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => League.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load public leagues');
    }
  }

  Future<List<League>> searchLeaguesByName(String name, String token) async {
    final url = Uri.parse('$_baseUrl/search/name?name=$name');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => League.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search leagues by name');
    }
  }

  Future<League> findLeagueByCode(String code, String token) async {
    final url = Uri.parse('$_baseUrl/search/code?code=$code');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return League.fromJson(json.decode(response.body));
    } else {
      throw Exception('League not found with this code');
    }
  }

  Future<void> joinPublicLeague(String joinCode, String token) async {
    final url = Uri.parse('$_baseUrl/join-by-code');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'joinCode': joinCode}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to join public league');
    }
  }

  Future<void> requestToJoinPrivateLeague(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/request-join');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send join request to private league');
    }
  }

  Future<List<int>> getMyPendingRequestLeagueIds(String token) async {
    final url = Uri.parse('$_baseUrl/my-pending-requests');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<int>().toList();
    } else {
      throw Exception('Failed to load pending requests');
    }
  }

  Future<void> cancelJoinRequest(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/request-join');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to cancel join request');
    }
  }

  Future<League> createLeague(String name, String? description, int teamSize, bool isPrivate, String token) async {
    final url = Uri.parse(_baseUrl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'description': description,
        'teamSize': teamSize,
        'isPrivate': isPrivate,
      }),
    );

    if (response.statusCode == 201) { 
      return League.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create league');
    }
  }

  Future<String> uploadLeagueImage(String leagueId, File imageFile, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/upload-image');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);
      return decodedData['imageUrl'];
    } else {
      throw Exception('Failed to upload league image');
    }
  }

  Future<int> getPendingJoinRequestsCount(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/requests');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> requests = json.decode(response.body);
      return requests.length;
    } else {
      throw Exception('Failed to load pending requests');
    }
  }

  Future<List<User>> getLeagueMembers(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/members');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> memberListJson = json.decode(response.body);
      return memberListJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load league members');
    }
  }
  
  Future<List<JoinRequest>> getPendingJoinRequests(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/requests');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> requestsJson = json.decode(response.body);
      final List<JoinRequest> validRequests = [];

      for (final requestData in requestsJson) {

        if (requestData is Map<String, dynamic> && requestData['userId'] != null) {
          validRequests.add(JoinRequest.fromJson(requestData));
        }
      }
      return validRequests;
    } else {
      throw Exception('Failed to load join requests');
    }
  }

  Future<void> acceptJoinRequest(int leagueId, int requestId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/requests/$requestId/accept');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept join request');
    }
  }

  Future<void> rejectJoinRequest(int leagueId, int requestId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/requests/$requestId/reject');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reject join request');
    }
  }

  Future<Map<String, dynamic>> updateLeague(int leagueId, Map<String, dynamic> leagueData, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(leagueData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update league. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getLeagueById(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load league details');
    }
  }

  Future<void> leaveLeague(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/leave');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al abandonar la liga');
    }
  }

  Future<void> deleteLeague(int leagueId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.body.isNotEmpty) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Error al eliminar la liga');
      }
      throw Exception('Error al eliminar la liga');
    }
  }

  Future<void> expelUser(int leagueId, int targetUserId, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/expel/$targetUserId');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode >= 300) {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al expulsar al usuario');
    }
  }

  Future<void> changeUserRole(int leagueId, int targetUserId, String newRole, String token) async {
    final url = Uri.parse('$_baseUrl/$leagueId/participants/$targetUserId/role');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'newRole': newRole}),
    );

    if (response.statusCode != 200) {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al cambiar el rol del usuario');
    }
  }
}