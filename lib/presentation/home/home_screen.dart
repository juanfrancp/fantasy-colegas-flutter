import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/presentation/league/league_home_screen.dart';
import 'package:fantasy_colegas_app/presentation/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/presentation/league/join_league_screen.dart';
import 'package:fantasy_colegas_app/presentation/league/create_league_screen.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

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
    _loadUserLeagues();
  }

  void _loadUserLeagues() {
    setState(() {
      _leaguesFuture = _leagueService.getMyLeagues();
    });
  }

  void _navigateAndReload(Widget screen) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => screen));
    if (result == true && mounted) {
      _loadUserLeagues();
    }
  }

  Widget _buildNoLeaguesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_soccer,
              size: 80,
              color: AppColors.secondaryAccent,
            ),
            const SizedBox(height: 20),
            Text(
              '¡Bienvenido a Fantasy Colegas!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.lightSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Parece que todavía no estás en ninguna liga.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightSurface),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _navigateAndReload(const JoinLeagueScreen()),
              icon: const Icon(
                Icons.group_add,
                color: AppColors.darkBackground,
              ),
              label: const Text(
                'Únete a una liga',
                style: TextStyle(
                  color: AppColors.darkBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _navigateAndReload(const CreateLeagueScreen()),
              icon: const Icon(Icons.add, color: AppColors.pureWhite),
              label: const Text(
                'Crea una liga',
                style: TextStyle(
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                minimumSize: const Size(double.infinity, 50),
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

        final bool hasImage = league.image != null && league.image!.isNotEmpty;
        final String? fullImageUrl = hasImage
            ? '${ApiConfig.serverUrl}${league.image}'
            : null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            color: AppColors.darkBackground.withAlpha(204),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: AppColors.secondaryAccent,
                width: 1.5,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.secondaryAccent,
                child: ClipOval(
                  child: hasImage
                      ? Image.network(
                          fullImageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/default_league.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/default_league.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              title: Text(
                league.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightSurface,
                ),
              ),
              subtitle: Text(
                league.description ?? 'Sin descripción',
                style: const TextStyle(color: AppColors.pureWhite),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        LeagueHomeScreen(initialLeague: league),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Mis Ligas',
          style: TextStyle(color: AppColors.lightSurface),
        ),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.lightSurface),
      ),
      drawer: AppDrawer(onLeaguesChanged: _loadUserLeagues),
      body: RefreshIndicator(
        onRefresh: () async => _loadUserLeagues(),
        color: AppColors.primaryAccent,
        backgroundColor: AppColors.darkBackground,
        child: FutureBuilder<List<League>>(
          future: _leaguesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryAccent,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.primaryAccent),
                ),
              );
            } else if (snapshot.hasData) {
              final leagues = snapshot.data!;
              if (leagues.isEmpty) {
                return _buildNoLeaguesView();
              } else {
                return _buildLeaguesListView(leagues);
              }
            }
            return const Center(
              child: Text(
                'No se encontraron ligas.',
                style: TextStyle(color: AppColors.lightSurface),
              ),
            );
          },
        ),
      ),
    );
  }
}
