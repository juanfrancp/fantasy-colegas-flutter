import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:fantasy_colegas_app/core/config/api_config.dart';


class AuthRepository {
  final String _baseUrl = '${ApiConfig.baseUrl}/auth';

  Future<String?> login(String usernameOrEmail, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usernameOrEmail': usernameOrEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['jwt'];
      } else {
        log('Error en el login (repository): ${response.statusCode}');
        log('Respuesta (repository): ${response.body}');
        return null;
      }
    } catch (e) {
      log('Excepción en AuthRepository.login: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final url = Uri.parse('$_baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        try {
          final errorData = json.decode(response.body);
          return {'errors': errorData};
        } catch (e) {
          return {'error': response.body};
        }
      }
    } catch (e) {
      return {'error': 'No se pudo conectar al servidor.'};
    }
  }
}