
import 'dart:developer';
import 'package:fantasy_colegas_app/data/models/user_score.dart';

import '../../data/models/user.dart';
import '/data/repositories/user_repository.dart';
import 'auth_service.dart';
import 'dart:io';


class UserService {
  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();

  Future<User?> getMe() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }
      return await _userRepository.getMe(token);
    } catch (e) {
      log('Error getting user profile (service): $e');
      return null;
    }
  }

  Future<bool> updateProfile({required String username, required String email}) async {
    try {
        final token = await _authService.getToken();
        if (token == null) throw Exception('Token not found');

        final response = await _userRepository.updateUser(username, email, token);

        if (response != null && response['newJwt'] != null) {
            final newJwt = response['newJwt'] as String;
            await _authService.saveToken(newJwt);
            return true;
        }
        return false;
    } catch (e) {
        log('Error updating user profile (service): $e');
        return false;
    }
  }

  Future<User?> uploadProfileImage(File imageFile) async {
    try {
        final token = await _authService.getToken();
        if (token == null) throw Exception('Token not found');
        return await _userRepository.uploadProfileImage(imageFile, token);
    } catch (e) {
        log('Error subiendo imagen de perfil (service): $e');
        return null;
    }
  }

  // TODO: Reemplazar con una llamada real a la API cuando el endpoint exista.
  Future<List<UserScore>> getUserLastScores(int leagueId, int userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      UserScore(userId: userId, username: 'Admin', totalPoints: 12.5),
      UserScore(userId: userId, username: 'Admin', totalPoints: 3),
      UserScore(userId: userId, username: 'Admin', totalPoints: 6.5),
    ];
  }
}