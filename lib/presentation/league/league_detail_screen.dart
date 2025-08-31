import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/user_standings.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

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
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          widget.league.name,
          style: const TextStyle(color: AppColors.lightSurface),
        ),
        backgroundColor: AppColors.darkBackground,
        iconTheme: const IconThemeData(color: AppColors.lightSurface),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Clasificación',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.lightSurface,
              ),
            ),
          ),
          const Divider(color: AppColors.secondaryAccent),
          Expanded(
            child: FutureBuilder<List<UserStandings>>(
              future: _scoreboardFuture,
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
                  final scoreboard = snapshot.data!;
                  if (scoreboard.isEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontró la clasificación.',
                        style: TextStyle(color: AppColors.lightSurface),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: scoreboard.length,
                    itemBuilder: (context, index) {
                      final score = scoreboard[index];
                      return Card(
                        color: AppColors.darkBackground.withAlpha(200),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.lightSurface,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppColors.darkBackground,
                              ),
                            ),
                          ),
                          title: Text(
                            score.username,
                            style: const TextStyle(
                              color: AppColors.lightSurface,
                            ),
                          ),
                          trailing: Text(
                            '${score.totalPoints.toStringAsFixed(2)} Pts',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryAccent,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: Text(
                    'No se encontró la clasificación.',
                    style: TextStyle(color: AppColors.lightSurface),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
