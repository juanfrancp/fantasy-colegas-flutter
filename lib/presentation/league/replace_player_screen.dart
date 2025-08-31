import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/roster_player.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/domain/services/roster_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class ReplacePlayerScreen extends StatefulWidget {
  final int leagueId;
  final RosterPlayer playerToReplace;

  const ReplacePlayerScreen({
    super.key,
    required this.leagueId,
    required this.playerToReplace,
  });

  @override
  State<ReplacePlayerScreen> createState() => _ReplacePlayerScreenState();
}

class _ReplacePlayerScreenState extends State<ReplacePlayerScreen> {
  final RosterService _rosterService = RosterService();
  late Future<List<Player>> _availablePlayersFuture;

  @override
  void initState() {
    super.initState();
    _availablePlayersFuture = _rosterService.getAvailablePlayers(
      widget.leagueId,
    );
  }

  Future<void> _onPlayerSelected(Player selectedPlayer) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final success = await _rosterService.replacePlayer(
      leagueId: widget.leagueId,
      playerToRemoveId: widget.playerToReplace.playerId,
      playerToAddId: selectedPlayer.id,
    );

    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('¡Jugador reemplazado!'),
          backgroundColor: AppColors.secondaryAccent,
        ),
      );
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Error al reemplazar el jugador.'),
          backgroundColor: AppColors.primaryAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        widget.playerToReplace.image != null &&
        widget.playerToReplace.image!.isNotEmpty;
    final fullImageUrl = hasImage
        ? '${ApiConfig.serverUrl}${widget.playerToReplace.image}'
        : null;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Reemplazar Jugador',
          style: TextStyle(color: AppColors.lightSurface),
        ),
        backgroundColor: AppColors.darkBackground,
        iconTheme: const IconThemeData(color: AppColors.lightSurface),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.secondaryAccent, width: 2),
              borderRadius: BorderRadius.circular(12.0),
              color: AppColors.darkBackground.withAlpha(200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.lightSurface,
                  backgroundImage: hasImage
                      ? NetworkImage(fullImageUrl!)
                      : const AssetImage('assets/images/default_profile.png')
                            as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reemplazando a:',
                        style: TextStyle(color: AppColors.secondaryAccent),
                      ),
                      Text(
                        widget.playerToReplace.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.lightSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Selecciona un jugador disponible:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.lightSurface,
              ),
            ),
          ),
          const Divider(color: AppColors.secondaryAccent),

          Expanded(
            child: FutureBuilder<List<Player>>(
              future: _availablePlayersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAccent,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.primaryAccent),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay jugadores disponibles.',
                      style: TextStyle(color: AppColors.lightSurface),
                    ),
                  );
                }

                final availablePlayers = snapshot.data!;
                return ListView.builder(
                  itemCount: availablePlayers.length,
                  itemBuilder: (context, index) {
                    final player = availablePlayers[index];
                    final hasPlayerImage =
                        player.image != null && player.image!.isNotEmpty;
                    final playerImageUrl = hasPlayerImage
                        ? '${ApiConfig.serverUrl}${player.image}'
                        : null;

                    return Card(
                      color: AppColors.darkBackground.withAlpha(200),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.lightSurface,
                          backgroundImage: hasPlayerImage
                              ? NetworkImage(playerImageUrl!)
                              : const AssetImage(
                                      'assets/images/default_player.png',
                                    )
                                    as ImageProvider,
                        ),
                        title: Text(
                          player.name,
                          style: const TextStyle(color: AppColors.lightSurface),
                        ),
                        trailing: Text(
                          '${player.totalPoints} pts',
                          style: const TextStyle(
                            color: AppColors.secondaryAccent,
                          ),
                        ),
                        onTap: () => _onPlayerSelected(player),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
