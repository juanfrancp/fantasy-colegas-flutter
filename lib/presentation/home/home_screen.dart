import 'package:fantasy_colegas_app/presentation/league/league_home_screen.dart';
import 'package:fantasy_colegas_app/presentation/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/presentation/league/join_league_screen.dart';
import 'package:fantasy_colegas_app/presentation/league/create_league_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<League>> _leaguesFuture;
  final LeagueService _leagueService = LeagueService();

  @override
  void initState() {
    super.initState();
    _leaguesFuture = _leagueService.getMyLeagues();
  }

  void _loadUserLeagues() {
    setState(() {
      _leaguesFuture = _leagueService.getMyLeagues();
    });
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
                builder: (context) => LeagueHomeScreen(league: league),
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
      _loadUserLeagues();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fantasy Colegas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(), 
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