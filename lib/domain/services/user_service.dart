
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
}