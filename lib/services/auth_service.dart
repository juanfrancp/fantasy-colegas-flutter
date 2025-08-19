import 'dart:convert'; // Para codificar y decodificar JSON
import 'package:http/http.dart' as http; // El paquete http que instalamos

class AuthService {
  // La URL base de tu API. Recuerda usar 10.0.2.2 para el emulador de Android
  final String _baseUrl = 'http://10.0.2.2:8080/api/auth';

  Future<String?> login(String usernameOrEmail, String password) async {
    // Construimos la URL completa para el endpoint de login
    final url = Uri.parse('$_baseUrl/login');

    try {
      // Hacemos la petición POST a tu backend
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'usernameOrEmail': usernameOrEmail,
          'password': password,
        }),
      );

      // Comprobamos si la petición fue exitosa (código 200)
      if (response.statusCode == 200) {
        // Decodificamos la respuesta JSON que nos envía el backend
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Extraemos el token JWT
        final String token = responseData['jwt'];
        print('Login exitoso! Token: $token');
        return token;
      } else {
        // Si el login falla (ej. contraseña incorrecta), el backend devuelve otro código
        print('Error en el login: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      // Capturamos cualquier error de conexión (ej. el backend no está encendido)
      print('Excepción al intentar hacer login: $e');
      return null;
    }
  }
}