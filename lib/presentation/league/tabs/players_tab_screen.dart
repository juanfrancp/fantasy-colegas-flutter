import 'package:fantasy_colegas_app/presentation/league/tabs/widgets/player_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/presentation/league/create_player_screen.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

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
  final TextEditingController _searchController = TextEditingController();

  late List<Player> _allPlayers;
  late List<Player> _filteredPlayers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _allPlayers = [];
    _filteredPlayers = [];
    _loadPlayers();
    _searchController.addListener(_filterPlayers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    try {
      final players = await _leagueService.getLeaguePlayers(widget.league.id);
      setState(() {
        _allPlayers = players;
        _filteredPlayers = _allPlayers;
        _isLoading = false;
        _sortPlayers(_filteredPlayers);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar jugadores: $e'),
            backgroundColor: AppColors.primaryAccent,
          ),
        );
      }
    }
  }

  void _filterPlayers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPlayers = _allPlayers.where((player) {
        return player.name.toLowerCase().contains(query);
      }).toList();
      _sortPlayers(_filteredPlayers);
    });
  }

  void _sortPlayers(List<Player> playerList) {
    playerList.sort((a, b) {
      final pointsComparison = b.totalPoints.compareTo(a.totalPoints);
      if (pointsComparison == 0) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return pointsComparison;
    });
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreatePlayerScreen(leagueId: widget.league.id),
      ),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      await _loadPlayers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.lightSurface),
              decoration: InputDecoration(
                labelText: 'Buscar jugador por nombre',
                labelStyle: const TextStyle(color: AppColors.secondaryAccent),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.secondaryAccent,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: AppColors.secondaryAccent.withAlpha(100),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: AppColors.lightSurface),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          Expanded(child: _buildPlayerList()),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _navigateAndRefresh,
              tooltip: 'Añadir Jugador',
              backgroundColor: AppColors.primaryAccent,
              child: const Icon(Icons.add, color: AppColors.pureWhite),
            )
          : null,
    );
  }

  Widget _buildPlayerList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAccent),
      );
    }
    if (_allPlayers.isEmpty) {
      return const Center(
        child: Text(
          'No hay jugadores en esta liga.',
          style: TextStyle(color: AppColors.lightSurface),
        ),
      );
    }
    if (_filteredPlayers.isEmpty) {
      return const Center(
        child: Text(
          'No se han encontrado jugadores con ese nombre.',
          style: TextStyle(color: AppColors.lightSurface),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredPlayers.length,
      itemBuilder: (context, index) {
        final player = _filteredPlayers[index];
        final hasImage = player.image != null && player.image!.isNotEmpty;
        final fullImageUrl = hasImage
            ? '${ApiConfig.serverUrl}${player.image}'
            : null;

        return Card(
          color: AppColors.darkBackground.withAlpha(200),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => PlayerInfoDialog(
                  leagueId: widget.league.id,
                  player: player,
                  isAdmin: widget.isAdmin,
                  onDataChanged: _loadPlayers,
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: AppColors.lightSurface,
              backgroundImage: hasImage
                  ? NetworkImage(fullImageUrl!)
                  : const AssetImage('assets/images/default_player.png')
                        as ImageProvider,
              onBackgroundImageError: (_, __) {},
            ),
            title: Text(
              player.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.lightSurface,
              ),
            ),
            trailing: Text(
              '${player.totalPoints} pts',
              style: const TextStyle(
                color: AppColors.secondaryAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
