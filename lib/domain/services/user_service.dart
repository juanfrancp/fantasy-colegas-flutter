// Archivo: lib/domain/services/user_service.dart

import 'dart:developer';
import 'dart:io';
import 'package:fantasy_colegas_app/core/api_client.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';
import 'package:fantasy_colegas_app/data/repositories/user_repository.dart';
import 'auth_service.dart';

class UserService {
  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();

  /// Helper que envuelve cada llamada al repositorio.
  /// Obtiene el token y maneja los errores de forma centralizada.
  Future<T> _executeWithAuth<T>(Future<T> Function(String token) action) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Sesión inválida. Por favor, inicia sesión de nuevo.');
    }
    try {
      return await action(token);
    } on ApiException catch (e) {
      log('Error de API en UserService: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      log('Error inesperado en UserService: $e');
      throw Exception('Ocurrió un error inesperado.');
    }
  }

  Future<User> getMe() =>
      _executeWithAuth((token) => _userRepository.getMe(token));

  Future<void> uploadProfileImage(File imageFile) =>
      _executeWithAuth((token) => _userRepository.uploadProfileImage(imageFile, token));

  // Este método es especial porque tiene lógica de negocio adicional (guardar el token)
  Future<void> updateProfile({required String username, required String email}) async {
    await _executeWithAuth((token) async {
      final response = await _userRepository.updateUser(username, email, token);
      
      // Si el backend devuelve un nuevo token JWT, lo guardamos
      if (response['newJwt'] != null) {
        final newJwt = response['newJwt'] as String;
        await _authService.saveToken(newJwt);
      }
    });
  }
}