import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/presentation/league/league_detail_screen.dart';
import 'package:fantasy_colegas_app/domain/services/auth_service.dart';
import 'package:fantasy_colegas_app/domain/services/user_service.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';
import 'package:fantasy_colegas_app/presentation/auth/login_screen.dart';
import 'package:fantasy_colegas_app/presentation/profile/profile_screen.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/presentation/league/join_league_screen.dart';
import 'package:fantasy_colegas_app/presentation/league/create_league_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<League>> _leaguesFuture;
  late Future<User?> _userFuture;
  final LeagueService _leagueService = LeagueService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _leaguesFuture = _leagueService.getMyLeagues();
    _userFuture = _userService.getMe();
  }

  void _loadUserLeagues() {
    setState(() {
      _leaguesFuture = _leagueService.getMyLeagues();
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildNoLeaguesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_soccer, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              '¡Bienvenido a Fantasy Colegas!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Parece que todavía no estás en ninguna liga.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _navigateToJoinLeagueScreen,
              icon: const Icon(Icons.group_add),
              label: const Text('Únete a una liga'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToCreateLeagueScreen,
              icon: const Icon(Icons.add),
              label: const Text('Crea una liga'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaguesListView(List<League> leagues) {
    return ListView.builder(
      itemCount: leagues.length,
      itemBuilder: (context, index) {
        final league = leagues[index];
        return ListTile(
          title: Text(league.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(league.description ?? 'Sin descripción'),
          leading: const Icon(Icons.shield_outlined),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LeagueDetailScreen(league: league),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToJoinLeagueScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinLeagueScreen()),
    );

    if (result == true && mounted) {
      _loadUserLeagues();
    }
  }

  void _navigateToCreateLeagueScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateLeagueScreen()),
    );
    if (result == true && mounted) {
      _loadUserLeagues(); // Este es tu método para recargar las ligas
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fantasy Colegas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // --- SECCIÓN 1: PERFIL DE USUARIO ---
            FutureBuilder<User?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.deepPurple),
                    child: Center(child: CircularProgressIndicator(color: Colors.white)),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  final user = snapshot.data!;
                  return UserAccountsDrawerHeader(
                    accountName: Text(user.username),
                    accountEmail: null,
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                          ? NetworkImage(ApiConfig.serverUrl + user.profileImageUrl!)
                          : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                      backgroundColor: Colors.white,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                    ),
                  );
                } else {
                  return const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.deepPurple),
                    child: Text('Error al cargar perfil', style: TextStyle(color: Colors.white)),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modificar perfil'),
              onTap: () async{
                Navigator.pop(context);
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
                setState(() {
                  _userFuture = _userService.getMe();
                });
              },
            ),
            const Divider(),

            // --- SECCIÓN 2: LIGAS ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Mis Ligas', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            FutureBuilder<List<League>>(
              future: _leaguesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Column(
                    children: snapshot.data!.map((league) {
                      return ListTile(
                        leading: const Icon(Icons.shield),
                        title: Text(league.name),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LeagueDetailScreen(league: league),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Únete a una liga'),
              onTap: () {
                Navigator.pop(context);
                _navigateToJoinLeagueScreen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Crea una liga'),
              onTap: () {
                Navigator.pop(context);
                _navigateToCreateLeagueScreen();
              },
            ),
            const Divider(),

            // --- SECCIÓN 3: OPCIONES ---
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Enviar comentarios'),
              onTap: () {
                // TODO: Implementar funcionalidad de feedback
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                _handleLogout();
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<League>>(
        future: _leaguesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final leagues = snapshot.data!;
            if (leagues.isEmpty) {
              return _buildNoLeaguesView();
            } else {
              return _buildLeaguesListView(leagues);
            }
          }
          return const Center(child: Text('No se encontraron ligas.'));
        },
      ),
    );
  }
}