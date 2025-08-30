import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository = AuthRepository();
  String? _token;

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    return _token;
  }

  Future<bool> login(String usernameOrEmail, String password, {bool rememberMe = false}) async {
    try {
      final newJwt = await _authRepository.login(usernameOrEmail, password);
      await _saveToken(newJwt, rememberMe: rememberMe); 
      log('Login exitoso! Token gestionado.');
      return true;
    } on AuthException catch (e) {
      log('Error de login (AuthService): ${e.message}');
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      await _authRepository.register(username, email, password);
      return true;
    } on AuthException catch (e) {
      log('Error de registro (AuthService): ${e.message}');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = null;
    log('Sesión cerrada y token eliminado.');
  }

  Future<void> _saveToken(String token, {required bool rememberMe}) async {
    _token = token;
    if (rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      log('Token guardado de forma persistente.');
    } else {
      log('Token guardado solo para la sesión actual.');
    }
  }

  Future<void> saveToken(String token) async {
    await _saveToken(token, rememberMe: true);
  }
}