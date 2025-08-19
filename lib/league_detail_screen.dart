import 'package:flutter/material.dart';
import 'models/league.dart';
import 'models/user_score.dart'; // Importamos el nuevo modelo
import 'services/league_service.dart'; // Importamos el servicio

// Convertimos la pantalla a un StatefulWidget
class LeagueDetailScreen extends StatefulWidget {
  final League league;

  const LeagueDetailScreen({super.key, required this.league});

  @override
  State<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends State<LeagueDetailScreen> {
  late Future<List<UserScore>> _scoreboardFuture;
  final LeagueService _leagueService = LeagueService();

  @override
  void initState() {
    super.initState();
    // En cuanto la pantalla carga, pedimos el marcador
    _scoreboardFuture = _leagueService.getScoreboard(widget.league.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.league.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de detalles (la que ya teníamos)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Clasificación',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          // Línea divisoria
          const Divider(),

          // Usamos Expanded para que la lista ocupe el espacio restante
          Expanded(
            child: FutureBuilder<List<UserScore>>(
              future: _scoreboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final scoreboard = snapshot.data!;
                  return ListView.builder(
                    itemCount: scoreboard.length,
                    itemBuilder: (context, index) {
                      final score = scoreboard[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'), // Posición en el ranking
                        ),
                        title: Text(score.username),
                        trailing: Text(
                          '${score.totalPoints.toStringAsFixed(2)} Pts', // Puntos con 2 decimales
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('No se encontró la clasificación.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}