import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/roster_player.dart';
import 'package:fantasy_colegas_app/domain/services/roster_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/presentation/league/replace_player_screen.dart';
import 'widgets/player_position_widget.dart';

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

  // --- NUEVA FUNCIÓN PARA NAVEGAR A LA PANTALLA DE REEMPLAZO ---
  void _navigateToReplacePlayer(RosterPlayer playerToReplace) async {
    // No se puede reemplazar un hueco vacío (jugador con ID 0)
    if (playerToReplace.playerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes cambiar un hueco vacío.')),
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

    // Si la pantalla de reemplazo devuelve 'true', refrescamos el equipo
    if (result == true) {
      setState(() {
        _rosterFuture = _rosterService.getUserRoster(widget.league.id);
      });
    }
  }

  List<Widget> _buildFormation(List<RosterPlayer> roster) {
    List<Widget> playerWidgets = [];

    // Lógica para separar jugadores (la mantenemos)
    RosterPlayer? goalkeeper;
    List<RosterPlayer> fieldPlayers = [];
    for (var player in roster) {
      if (player.role.toUpperCase() == 'PORTERO') {
        goalkeeper = player;
      } else if (player.role.toUpperCase() == 'CAMPO') {
        fieldPlayers.add(player);
      }
    }
    goalkeeper ??= RosterPlayer(playerId: 0, name: 'Portero', role: 'PORTERO', totalPoints: 0);

    // --- PORTERO (siempre igual) ---
    playerWidgets.add(
      Positioned(
        bottom: 15,
        left: 0,
        right: 0,
        child: PlayerPositionWidget(
          playerName: goalkeeper.name,
          playerImageUrl: goalkeeper.image != null ? '${ApiConfig.serverUrl}${goalkeeper.image}' : null,
          position: 'POR',
          positionBackgroundColor: Colors.amber,
          onTap: () => _navigateToReplacePlayer(goalkeeper!),
        ),
      ),
    );

    // --- LÓGICA DE FORMACIONES ---
    if (widget.league.teamSize == 3) {
      // --- Formación 1-2 ---
      playerWidgets.add(
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(2, (index) {
              final player = index < fieldPlayers.length
                  ? fieldPlayers[index]
                  : RosterPlayer(playerId: 0, name: 'Jugador ${index + 1}', role: 'CAMPO', totalPoints: 0);
              return PlayerPositionWidget(
                playerName: player.name,
                playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                position: 'CAM',
                positionBackgroundColor: Colors.blue[300],
                onTap: () => _navigateToReplacePlayer(player),
              );
            }),
          ),
        ),
      );
    } else if (widget.league.teamSize == 4) {
      // --- Formación 1-2-1 ---
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(playerId: 0, name: 'Jugador ${index + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                  position: 'CAM',
                  positionBackgroundColor: Colors.blue[300],
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
            child: Builder(builder: (context) {
              final player = 2 < fieldPlayers.length
                  ? fieldPlayers[2]
                  : RosterPlayer(playerId: 0, name: 'Jugador 3', role: 'CAMPO', totalPoints: 0);
              return PlayerPositionWidget(
                playerName: player.name,
                playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                position: 'CAM',
                positionBackgroundColor: Colors.blue[300],
                onTap: () => _navigateToReplacePlayer(player),
              );
            }),
          ),
        ),
      );
    }
    // --- NUEVA LÓGICA PARA TAMAÑO 5 ---
    else if (widget.league.teamSize == 5) {
      // --- Formación 1-2-2 (cuadrado) ---

      // 1. Los dos jugadores de atrás (por debajo del medio campo)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.3), // Misma altura que en la formación de 4
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(playerId: 0, name: 'Jugador ${index + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                  position: 'CAM',
                  positionBackgroundColor: Colors.blue[300],
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );

      // 2. Los dos jugadores de arriba (por encima del medio campo)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.3), // Misma altura que en la formación de 4
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                // Empezamos a contar desde el tercer jugador de campo (índice 2)
                final playerIndex = index + 2; 
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(playerId: 0, name: 'Jugador ${playerIndex + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                  position: 'CAM',
                  positionBackgroundColor: Colors.blue[300],
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
    }
    else if (widget.league.teamSize == 6) {
      // --- Formación 1-2-1-2 ---

      // 1. Los dos jugadores de atrás (defensas)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.4), // Por debajo del medio campo
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(playerId: 0, name: 'Jugador ${index + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                  position: 'CAM',
                  positionBackgroundColor: Colors.blue[300],
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );

      // 2. El jugador del medio
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.0), // Justo en el medio campo
            child: Builder(builder: (context) {
              final playerIndex = 2; // El tercer jugador de campo
              final player = playerIndex < fieldPlayers.length
                  ? fieldPlayers[playerIndex]
                  : RosterPlayer(playerId: 0, name: 'Jugador 3', role: 'CAMPO', totalPoints: 0);
              return PlayerPositionWidget(
                playerName: player.name,
                playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                position: 'CAM',
                positionBackgroundColor: Colors.blue[300],
                onTap: () => _navigateToReplacePlayer(player),
              );
            }),
          ),
        ),
      );

      // 3. Los dos jugadores de arriba (delanteros)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.4), // Por encima del medio campo
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final playerIndex = index + 3; // El cuarto y quinto jugador de campo
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(playerId: 0, name: 'Jugador ${playerIndex + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                  position: 'CAM',
                  positionBackgroundColor: Colors.blue[300],
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
    }
    // --- NUEVA LÓGICA PARA TAMAÑO 7 ---
  else if (widget.league.teamSize == 7) {
    // --- Formación 1-3-1-2 ---

    // 1. Los tres jugadores de atrás (defensas)
    playerWidgets.add(
      Positioned.fill(
        child: Align(
          alignment: const Alignment(0.0, 0.5), // Un poco más atrás que en otras formaciones
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              final player = index < fieldPlayers.length
                  ? fieldPlayers[index]
                  : RosterPlayer(playerId: 0, name: 'Jugador ${index + 1}', role: 'CAMPO', totalPoints: 0);
              return PlayerPositionWidget(
                playerName: player.name,
                playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                position: 'CAM',
                positionBackgroundColor: Colors.blue[300],
                onTap: () => _navigateToReplacePlayer(player),
              );
            }),
          ),
        ),
      ),
    );

    // 2. El jugador del medio
    playerWidgets.add(
      Positioned.fill(
        child: Align(
          alignment: const Alignment(0.0, 0.0), // Justo en el medio campo
          child: Builder(builder: (context) {
            final playerIndex = 3; // El cuarto jugador de campo
            final player = playerIndex < fieldPlayers.length
                ? fieldPlayers[playerIndex]
                : RosterPlayer(playerId: 0, name: 'Jugador 4', role: 'CAMPO', totalPoints: 0);
            return PlayerPositionWidget(
              playerName: player.name,
              playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
              position: 'CAM',
              positionBackgroundColor: Colors.blue[300],
              onTap: () => _navigateToReplacePlayer(player),
            );
          }),
        ),
      ),
    );

    // 3. Los dos jugadores de arriba (delanteros)
    playerWidgets.add(
      Positioned.fill(
        child: Align(
          alignment: const Alignment(0.0, -0.5), // Un poco más adelantados
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(2, (index) {
              final playerIndex = index + 4; // El quinto y sexto jugador de campo
              final player = playerIndex < fieldPlayers.length
                  ? fieldPlayers[playerIndex]
                  : RosterPlayer(playerId: 0, name: 'Jugador ${playerIndex + 1}', role: 'CAMPO', totalPoints: 0);
              return PlayerPositionWidget(
                playerName: player.name,
                playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                position: 'CAM',
                positionBackgroundColor: Colors.blue[300],
                onTap: () => _navigateToReplacePlayer(player),
              );
            }),
          ),
        ),
      ),
    );
  }
    // --- NUEVA LÓGICA PARA TAMAÑO 8 ---
    else if (widget.league.teamSize == 8) {
      // --- Formación 1-3-2-2 ---

      // 1. Los tres jugadores de atrás (defensas)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.5), // Bastante atrás
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final player = index < fieldPlayers.length
                    ? fieldPlayers[index]
                    : RosterPlayer(playerId: 0, name: 'Jugador ${index + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                  position: 'CAM',
                  positionBackgroundColor: Colors.blue[300],
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );

      // 2. Los dos jugadores del medio
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.0), // Ligeramente por debajo del centro
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                  final playerIndex = index + 3; // El cuarto y quinto jugador
                  final player = playerIndex < fieldPlayers.length
                      ? fieldPlayers[playerIndex]
                      : RosterPlayer(playerId: 0, name: 'Jugador ${playerIndex + 1}', role: 'CAMPO', totalPoints: 0);
                  return PlayerPositionWidget(
                      playerName: player.name,
                      playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                      position: 'CAM',
                      positionBackgroundColor: Colors.blue[300],
                      onTap: () => _navigateToReplacePlayer(player),
                  );
              }),
            ),
          ),
        ),
      );

      // 3. Los dos jugadores de arriba (delanteros)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.5), // Más adelantados
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final playerIndex = index + 5; // El sexto y séptimo jugador
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(playerId: 0, name: 'Jugador ${playerIndex + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(
                  playerName: player.name,
                  playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                  position: 'CAM',
                  positionBackgroundColor: Colors.blue[300],
                  onTap: () => _navigateToReplacePlayer(player),
                );
              }),
            ),
          ),
        ),
      );
    }
    // --- NUEVA LÓGICA PARA TAMAÑO 9 ---
  else if (widget.league.teamSize == 9) {
    // --- Formación 1-4-2-2 ---

    // 1. Los cuatro jugadores de atrás (defensas)
    playerWidgets.add(
      Positioned.fill(
        child: Align(
          alignment: const Alignment(0.0, 0.6), // Bastante atrás
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              final player = index < fieldPlayers.length
                  ? fieldPlayers[index]
                  : RosterPlayer(playerId: 0, name: 'Jugador ${index + 1}', role: 'CAMPO', totalPoints: 0);
              return PlayerPositionWidget(
                playerName: player.name,
                playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                position: 'CAM',
                positionBackgroundColor: Colors.blue[300],
                onTap: () => _navigateToReplacePlayer(player),
              );
            }),
          ),
        ),
      ),
    );

    // 2. Los dos jugadores del medio
    playerWidgets.add(
      Positioned.fill(
        child: Align(
          alignment: const Alignment(0.0, 0.1), // Ligeramente por debajo del centro
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(2, (index) {
                final playerIndex = index + 4; // El quinto y sexto jugador
                final player = playerIndex < fieldPlayers.length
                    ? fieldPlayers[playerIndex]
                    : RosterPlayer(playerId: 0, name: 'Jugador ${playerIndex + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(
                    playerName: player.name,
                    playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                    position: 'CAM',
                    positionBackgroundColor: Colors.blue[300],
                    onTap: () => _navigateToReplacePlayer(player),
                );
            }),
          ),
        ),
      ),
    );

    // 3. Los dos jugadores de arriba (delanteros)
    playerWidgets.add(
      Positioned.fill(
        child: Align(
          alignment: const Alignment(0.0, -0.4), // Más adelantados
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(2, (index) {
              final playerIndex = index + 6; // El séptimo y octavo jugador
              final player = playerIndex < fieldPlayers.length
                  ? fieldPlayers[playerIndex]
                  : RosterPlayer(playerId: 0, name: 'Jugador ${playerIndex + 1}', role: 'CAMPO', totalPoints: 0);
              return PlayerPositionWidget(
                playerName: player.name,
                playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null,
                position: 'CAM',
                positionBackgroundColor: Colors.blue[300],
                onTap: () => _navigateToReplacePlayer(player),
              );
            }),
          ),
        ),
      ),
    );
  }
  // --- NUEVA LÓGICA PARA TAMAÑO 10 ---
    else if (widget.league.teamSize == 10) {
      // --- Formación 1-4-3-2 ---

      // 1. Defensas (4 jugadores)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                final player = index < fieldPlayers.length ? fieldPlayers[index] : RosterPlayer(playerId: 0, name: 'Jugador ${index + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(playerName: player.name, playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null, position: 'CAM', positionBackgroundColor: Colors.blue[300], onTap: () => _navigateToReplacePlayer(player));
              }),
            ),
          ),
        ),
      );

      // 2. Medios (3 jugadores)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final playerIndex = index + 4;
                final player = playerIndex < fieldPlayers.length ? fieldPlayers[playerIndex] : RosterPlayer(playerId: 0, name: 'Jugador ${playerIndex + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(playerName: player.name, playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null, position: 'CAM', positionBackgroundColor: Colors.blue[300], onTap: () => _navigateToReplacePlayer(player));
              }),
            ),
          ),
        ),
      );

      // 3. Delanteros (2 jugadores)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) {
                final playerIndex = index + 7;
                final player = playerIndex < fieldPlayers.length ? fieldPlayers[playerIndex] : RosterPlayer(playerId: 0, name: 'Jugador ${playerIndex + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(playerName: player.name, playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null, position: 'CAM', positionBackgroundColor: Colors.blue[300], onTap: () => _navigateToReplacePlayer(player));
              }),
            ),
          ),
        ),
      );
    }
    // --- NUEVA LÓGICA PARA TAMAÑO 11 ---
    else if (widget.league.teamSize == 11) {
      // --- Formación 1-4-3-3 (el clásico 4-3-3) ---

      // 1. Defensas (4 jugadores)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                final player = index < fieldPlayers.length ? fieldPlayers[index] : RosterPlayer(playerId: 0, name: 'Jugador ${index + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(playerName: player.name, playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null, position: 'CAM', positionBackgroundColor: Colors.blue[300], onTap: () => _navigateToReplacePlayer(player));
              }),
            ),
          ),
        ),
      );

      // 2. Medios (3 jugadores)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final playerIndex = index + 4;
                final player = playerIndex < fieldPlayers.length ? fieldPlayers[playerIndex] : RosterPlayer(playerId: 0, name: 'Jugador ${playerIndex + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(playerName: player.name, playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null, position: 'CAM', positionBackgroundColor: Colors.blue[300], onTap: () => _navigateToReplacePlayer(player));
              }),
            ),
          ),
        ),
      );

      // 3. Delanteros (3 jugadores)
      playerWidgets.add(
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final playerIndex = index + 7;
                final player = playerIndex < fieldPlayers.length ? fieldPlayers[playerIndex] : RosterPlayer(playerId: 0, name: 'Jugador ${playerIndex + 1}', role: 'CAMPO', totalPoints: 0);
                return PlayerPositionWidget(playerName: player.name, playerImageUrl: player.image != null ? '${ApiConfig.serverUrl}${player.image}' : null, position: 'CAM', positionBackgroundColor: Colors.blue[300], onTap: () => _navigateToReplacePlayer(player));
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<RosterPlayer>>(
            future: _rosterFuture,
            builder: (context, snapshot) {
              final fieldWidget = Container(
                 decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(77), spreadRadius: 3, blurRadius: 7, offset: const Offset(0, 5))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset('assets/images/field.png', fit: BoxFit.contain),
                ),
              );

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Stack(children: [fieldWidget, const Center(child: CircularProgressIndicator())]);
              }
              if (snapshot.hasError) {
                return Stack(children: [fieldWidget, Center(child: Text('Error: ${snapshot.error}'))]);
              }
              if (!snapshot.hasData) {
                return Stack(children: [fieldWidget, const Center(child: Text('No se encontró el equipo.'))]);
              }

              final roster = snapshot.data!;
              return Stack(
                children: [
                  fieldWidget,
                  ..._buildFormation(roster),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}