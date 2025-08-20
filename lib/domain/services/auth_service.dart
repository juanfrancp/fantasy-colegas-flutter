import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository = AuthRepository();
  
  String? _token; 

  static final AuthService _instance = AuthService._internal();
  factory AuthService() {
    return _instance;
  }
  AuthService._internal();

  Future<String?> getToken() async {
    if (_token != null) return _token;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    return _token;
  }

  Future<String?> login(String usernameOrEmail, String password) async {
    final newJwt = await _authRepository.login(usernameOrEmail, password);

    if (newJwt != null) {
      _token = newJwt;
      log('Login exitoso! Token guardado en AuthService.');
    }
    return newJwt;
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    return await _authRepository.register(username, email, password);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = null;
    log('Sesión cerrada y token eliminado.');
  }

  Future<void> saveToken(String token) async {
        _token = token; // Actualiza el token en memoria
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token); // Guárdalo en el almacenamiento
        log('Nuevo token guardado.');
    }
}