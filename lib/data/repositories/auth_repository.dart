import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:fantasy_colegas_app/core/config/api_config.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthRepository {
  final String _baseUrl = '${ApiConfig.baseUrl}/auth';

  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else {
        throw AuthException(
          responseBody['message'] ?? 'Error desconocido',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Excepción en AuthRepository._post a $endpoint: $e');
      throw AuthException('No se pudo conectar al servidor. Inténtalo de nuevo.');
    }
  }

  Future<String> login(String usernameOrEmail, String password) async {
    final responseData = await _post('login', {
      'usernameOrEmail': usernameOrEmail,
      'password': password,
    });
    return responseData['jwt'];
  }

  Future<void> register(String username, String email, String password) async {
    await _post('register', {
      'username': username,
      'email': email,
      'password': password,
    });
  }
}