import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/user_standings.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';

class LeagueDetailScreen extends StatefulWidget {
  final League league;

  const LeagueDetailScreen({super.key, required this.league});

  @override
  State<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends State<LeagueDetailScreen> {
  late Future<List<UserStandings>> _scoreboardFuture;
  final LeagueService _leagueService = LeagueService();

  @override
  void initState() {
    super.initState();
    _scoreboardFuture = _leagueService.getLeagueStandings(widget.league.id);
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Clasificación',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<UserStandings>>(
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
                          child: Text('${index + 1}'),
                        ),
                        title: Text(score.username),
                        trailing: Text(
                          '${score.totalPoints.toStringAsFixed(2)} Pts',
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