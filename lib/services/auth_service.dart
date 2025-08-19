import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // --- Implementación del patrón Singleton ---
  static final AuthService _instance = AuthService._internal();
  factory AuthService() {
    return _instance;
  }
  AuthService._internal();
  // -----------------------------------------

  final String _baseUrl = 'http://10.0.2.2:8080/api/auth';
  String? _token; // Token en memoria para la sesión actual

  // NUEVO: Método para obtener el token de la sesión actual o del almacenamiento
  Future<String?> getToken() async {
    // Si ya tenemos el token en memoria, lo usamos
    if (_token != null) return _token;

    // Si no, intentamos cargarlo desde el almacenamiento persistente
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    return _token;
  }

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
        _token = responseData['jwt']; // Guardamos el token en memoria
        print('Login exitoso! Token: $_token');
        return _token;
      } else {
        print('Error en el login: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al intentar hacer login: $e');
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // Limpiamos el almacenamiento
    _token = null; // Limpiamos el token de la memoria
    print('Sesión cerrada y token eliminado.');
  }
}
