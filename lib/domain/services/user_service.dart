
import 'dart:developer';
import '../../data/models/user.dart';
import '/data/repositories/user_repository.dart';
import 'auth_service.dart';


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
                // Guarda el nuevo token
                await _authService.saveToken(newJwt);
                return true;
            }
            return false;
        } catch (e) {
            log('Error updating user profile (service): $e');
            return false;
        }
    }
}