import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/presentation/league/create_player_screen.dart';

class PlayersTabScreen extends StatefulWidget {
  final League league;
  final bool isAdmin;

  const PlayersTabScreen({
    super.key,
    required this.league,
    required this.isAdmin,
  });

  @override
  State<PlayersTabScreen> createState() => _PlayersTabScreenState();
}

class _PlayersTabScreenState extends State<PlayersTabScreen> {
  final LeagueService _leagueService = LeagueService();
  late Future<List<Player>> _playersFuture;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  void _loadPlayers() {
    setState(() {
      _playersFuture = _leagueService.getLeaguePlayers(widget.league.id);
    });
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreatePlayerScreen(leagueId: widget.league.id),
      ),
    );

    if (result == true) {
      _loadPlayers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Player>>(
        future: _playersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los jugadores: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay jugadores en esta liga.'));
          }

          final players = snapshot.data!;

          players.sort((a, b) {
            final pointsComparison = b.totalPoints.compareTo(a.totalPoints);
            if (pointsComparison == 0) {
              return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            }
            return pointsComparison;
          });

          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final hasImage = player.image != null && player.image!.isNotEmpty;
              final fullImageUrl = hasImage ? '${ApiConfig.serverUrl}${player.image}' : null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: hasImage
                        ? NetworkImage(fullImageUrl!)
                        : const AssetImage('assets/images/default_player.png') as ImageProvider,
                    onBackgroundImageError: (_, __) {},
                  ),
                  title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(
                    '${player.totalPoints} pts',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _navigateAndRefresh,
              tooltip: 'Añadir Jugador',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}