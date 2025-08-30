// Archivo: lib/data/repositories/user_repository.dart

import 'dart:io';
import 'package:fantasy_colegas_app/core/api_client.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import '../models/user.dart';

class UserRepository {
  final String _baseUrl = '${ApiConfig.baseUrl}/users';

  // Helper para obtener una instancia del ApiClient con el token
  ApiClient _client(String token) => ApiClient(baseUrl: _baseUrl, token: token);

  Future<User> getMe(String token) async {
    final jsonResponse = await _client(token).get('me');
    return User.fromJson(jsonResponse);
  }

  Future<Map<String, dynamic>> updateUser(String username, String email, String token) async {
    final body = {'username': username, 'email': email};
    // Devuelve el mapa completo porque el backend puede enviar un nuevo JWT junto con los datos del usuario
    return await _client(token).put('me', body: body);
  }

  Future<User> uploadProfileImage(File imageFile, String token) async {
    // La subida de archivos es un caso especial y usa un ApiClient con la baseUrl general
    final jsonResponse = await ApiClient(baseUrl: ApiConfig.baseUrl, token: token)
        .multipartPost('users/me/profile-image', imageFile, 'image');
    
    // Asumimos que la respuesta de subir imagen devuelve el objeto User actualizado
    return User.fromJson(jsonResponse);
  }
}