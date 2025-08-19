import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/user.dart';

class UserService {
  final String _baseUrl = 'http://10.0.2.2:8080/api/users';
  final AuthService _authService = AuthService();

  Future<User?> getMe() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final url = Uri.parse('$_baseUrl/me');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener el perfil del usuario: $e');
      return null;
    }
  }
}