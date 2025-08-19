import 'package:flutter/material.dart';
import 'services/league_service.dart';
import 'models/league.dart';
import 'league_detail_screen.dart';
import 'services/auth_service.dart';
import 'main.dart'; // Para navegar a LoginScreen

// Convertimos HomeScreen a un StatefulWidget para que pueda manejar un estado
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Un "Future" que guardará el resultado de la llamada a la API
  late Future<List<League>> _leaguesFuture;
  final LeagueService _leagueService = LeagueService();
  final AuthService _authService = AuthService(); // Instancia del servicio

  @override
  void initState() {
    super.initState();
    // Hacemos la llamada a la API en cuanto la pantalla se carga
    _leaguesFuture = _leagueService.getMyLeagues();
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    // Navegamos de vuelta al login y eliminamos todas las rutas anteriores
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ligas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // NUEVO: Botón de cerrar sesión
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      // FutureBuilder se encarga de construir la UI según el estado del Future
      body: FutureBuilder<List<League>>(
        future: _leaguesFuture,
        builder: (context, snapshot) {
          // MIENTRAS CARGA
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          // SI HAY UN ERROR
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          // SI TODO FUE BIEN Y HAY DATOS
          else if (snapshot.hasData) {
            final leagues = snapshot.data!;
            // Construimos una lista que se puede desplazar
            return ListView.builder(
              itemCount: leagues.length,
              itemBuilder: (context, index) {
                final league = leagues[index];
                // ListTile es un widget perfecto para filas de una lista
                return ListTile(
                  title: Text(league.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(league.description ?? 'Sin descripción'),
                  leading: const Icon(Icons.shield_outlined),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        // Le decimos que construya nuestra nueva pantalla
                        // y le pasamos la liga actual de la lista
                        builder: (context) => LeagueDetailScreen(league: league),
                      ),
                    );
                  },
                );
              },
            );
          }
          // Por si acaso, un estado por defecto
          return const Center(child: Text('No se encontraron ligas.'));
        },
      ),
    );
  }
}
