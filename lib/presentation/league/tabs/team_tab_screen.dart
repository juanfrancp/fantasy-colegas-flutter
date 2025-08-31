import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/roster_player.dart';
import 'package:fantasy_colegas_app/domain/services/roster_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/presentation/league/replace_player_screen.dart';
import 'widgets/player_position_widget.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class TeamTabScreen extends StatefulWidget {
  final League league;

  const TeamTabScreen({super.key, required this.league});

  @override
  State<TeamTabScreen> createState() => _TeamTabScreenState();
}

class _TeamTabScreenState extends State<TeamTabScreen> {
  final RosterService _rosterService = RosterService();
  late Future<List<RosterPlayer>> _rosterFuture;

  @override
  void initState() {
    super.initState();
    _rosterFuture = _rosterService.getUserRoster(widget.league.id);
  }

  void _navigateToReplacePlayer(RosterPlayer playerToReplace) async {
    if (playerToReplace.playerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes cambiar un hueco vacío.'),
          backgroundColor: AppColors.primaryAccent,
        ),
      );
      return;
    }
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ReplacePlayerScreen(
          leagueId: widget.league.id,
          playerToReplace: playerToReplace,
        ),
      ),
    );
    if (result == true) {
      setState(() {
        _rosterFuture = _rosterService.getUserRoster(widget.league.id);
      });
    }
  }

  List<Widget> _buildFormation(List<RosterPlayer> roster) {
    List<Widget> playerWidgets = [];
    RosterPlayer? goalkeeper;
    List<RosterPlayer> fieldPlayers = [];
    for (var player in roster) {
      if (player.role.toUpperCase() == 'PORTERO') {
        goalkeeper = player;
      } else if (player.role.toUpperCase() == 'CAMPO') {
        fieldPlayers.add(player);
      }
    }
    goalkeeper ??= RosterPlayer(
      playerId: 0,
      name: 'Portero',
      role: 'PORTERO',
      totalPoints: 0,
    );
    playerWidgets.add(
      Positioned(
        bottom: 15,
        left: 0,
        right: 0,
        child: PlayerPositionWidget(
          playerName: goalkeeper.name,
          playerImageUrl: goalkeeper.image != null
              ? '${ApiConfig.serverUrl}${goalkeeper.image}'
              : null,
          position: 'POR',
          positionBackgroundColor: AppColors.secondaryAccent,
          onTap: () => _navigateToReplacePlayer(goalkeeper!),
        ),
      ),
    );
    if (widget.league.teamSize == 3) {
      playerWidgets.add(
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(2, (index) {
              final player = index < fieldPlayers.length
                  ? fieldPlayers[index]
                  : RosterPlayer(
                      playerId: 0,
                      name: 'Jugador ${index + 1}',
                      role: 'CAMPO',
                      totalPoints: 0,
                    );
              return PlayerPositionWidget(
                playerName: player.name,
                playerImageUrl: player.image != null
                    ? '${ApiConfig.serverUrl}${player.image}'
                    : null,
                position: 'CAM',
                positionBackgroundColor: AppColors.primaryAccent,
                onTap: () => _navigateToReplacePlayer(player),
              );
            }),
          ),
        ),
      );
    } else if (widget.league.teamSize == 4) {
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${index + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.3),
            child: Builder(
              builder: (context) {
                final player = 2 < fieldPlayers.length
                    ? fieldPlayers[2]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador 3',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              },
            ),
          ),
        ),
      );
    } else if (widget.league.teamSize == 5) {
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${index + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final playerIndex = index + 2;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${playerIndex + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
    } else if (widget.league.teamSize == 6) {
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${index + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.0),
            child: Builder(
              builder: (context) {
                final playerIndex = 2;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador 3',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              },
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final playerIndex = index + 3;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${playerIndex + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
    } else if (widget.league.teamSize == 7) {
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${index + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.0),
            child: Builder(
              builder: (context) {
                final playerIndex = 3;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador 4',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              },
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final playerIndex = index + 4;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${playerIndex + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
    } else if (widget.league.teamSize == 8) {
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${index + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final playerIndex = index + 3;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${playerIndex + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final playerIndex = index + 5;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${playerIndex + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
    } else if (widget.league.teamSize == 9) {
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${index + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final playerIndex = index + 4;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${playerIndex + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final playerIndex = index + 6;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${playerIndex + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
    } else if (widget.league.teamSize == 10) {
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${index + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final playerIndex = index + 4;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${playerIndex + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final playerIndex = index + 7;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${playerIndex + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
    } else if (widget.league.teamSize == 11) {
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${index + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final playerIndex = index + 4;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${playerIndex + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final playerIndex = index + 7;
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(
                        playerId: 0,
                        name: 'Jugador ${playerIndex + 1}',
                        role: 'CAMPO',
                        totalPoints: 0,
                      );
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null
                      ? '${ApiConfig.serverUrl}${player.image}'
                      : null,
                  position: 'CAM',
                  positionBackgroundColor: AppColors.primaryAccent,
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
    }
    return playerWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<RosterPlayer>>(
            future: _rosterFuture,
            builder: (context, snapshot) {
              final fieldWidget = Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(77),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    'assets/images/field.png',
                    fit: BoxFit.contain,
                  ),
                ),
              );

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Stack(
                  children: [
                    fieldWidget,
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ],
                );
              }
              if (snapshot.hasError) {
                return Stack(
                  children: [
                    fieldWidget,
                    Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: AppColors.primaryAccent),
                      ),
                    ),
                  ],
                );
              }
              if (!snapshot.hasData) {
                return Stack(
                  children: [
                    fieldWidget,
                    const Center(
                      child: Text(
                        'No se encontró el equipo.',
                        style: TextStyle(color: AppColors.lightSurface),
                      ),
                    ),
                  ],
                );
              }

              final roster = snapshot.data!;
              return Stack(children: [fieldWidget, ..._buildFormation(roster)]);
            },
          ),
        ),
      ),
    );
  }
}
