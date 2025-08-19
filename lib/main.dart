import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa el paquete
import 'services/auth_service.dart';
import 'home_screen.dart'; // Importa la pantalla de inicio
import 'register_screen.dart'; // Importa la nueva pantalla de registro
import 'auth_check_screen.dart'; // Importa la pantalla de comprobación

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantasy Colegas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthCheckScreen(), // La app ahora empieza aquí
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Variable de estado para la carga
  bool _isLoading = false;
  // NUEVO: Variable para la casilla de verificación
  bool _rememberMe = false;

  Future<void> _handleLogin() async {
    // Mostramos el indicador de carga
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    final token = await _authService.login(email, password);

    // Ocultamos el indicador de carga
    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (token != null) {
      // 1. Guardar el token solo si el usuario lo ha solicitado
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
      }

      // 2. Navegar a la pantalla de Home (reemplazando la de login)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario o contraseña incorrectos'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Fantasy Colegas Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email o Usuario', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                // MODIFICADO: Casilla para "Mantener sesión iniciada" alineada a la izquierda
                Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Cambiado de center a start
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('Mantener sesión iniciada'),
                  ],
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  // Desactivamos el botón si está cargando
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  // Mostramos el indicador o el texto
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white,) 
                      : const Text('Entrar'),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
