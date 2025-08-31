import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/presentation/league/schedule_match_screen.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class MatchesTabScreen extends StatefulWidget {
  final League league;
  final bool isAdmin;

  const MatchesTabScreen({super.key, required this.league, this.isAdmin = false});

  @override
  State<MatchesTabScreen> createState() => _MatchesTabScreenState();
}

class _MatchesTabScreenState extends State<MatchesTabScreen> {
  bool _showUpcomingMatches = true;

  // Datos de ejemplo
  final List<Map<String, String>> _upcomingMatches = [
    {"team1": "Equipo A", "team2": "Equipo B", "date": "25/12/2024"},
    {"team1": "Equipo C", "team2": "Equipo D", "date": "28/12/2024"},
  ];

  final List<Map<String, String>> _pastMatches = [
    {"team1": "Equipo X", "team2": "Equipo Y", "score": "2 - 1"},
    {"team1": "Equipo Z", "team2": "Equipo W", "score": "0 - 0"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Column(
        children: [
          _buildMatchToggleButtons(),
          Expanded(
            child: _showUpcomingMatches
                ? _buildMatchesList(_upcomingMatches, isUpcoming: true)
                : _buildMatchesList(_pastMatches, isUpcoming: false),
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScheduleMatchScreen(league: widget.league),
                  ),
                );
              },
              label: const Text('Programar Partido'),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.primaryAccent,
            )
          : null,
    );
  }

  Widget _buildMatchToggleButtons() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // Cambiado withOpacity a withAlpha
        color: AppColors.lightSurface.withAlpha(26), // 0.1 opacity
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _showUpcomingMatches = true),
              style: TextButton.styleFrom(
                backgroundColor: _showUpcomingMatches
                    ? AppColors.secondaryAccent
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text(
                'Próximos',
                style: TextStyle(
                  color: _showUpcomingMatches
                      ? AppColors.darkBackground
                      : AppColors.lightSurface,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _showUpcomingMatches = false),
              style: TextButton.styleFrom(
                backgroundColor: !_showUpcomingMatches
                    ? AppColors.secondaryAccent
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text(
                'Anteriores',
                style: TextStyle(
                  color: !_showUpcomingMatches
                      ? AppColors.darkBackground
                      : AppColors.lightSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList(
    List<Map<String, String>> matches, {
    required bool isUpcoming,
  }) {
    if (matches.isEmpty) {
      return Center(
        child: Text(
          isUpcoming
              ? 'Aún no hay partidos programados.'
              : 'No se han jugado partidos todavía.',
          style: const TextStyle(color: AppColors.lightSurface, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Card(
          // Cambiado withOpacity a withAlpha
          color: AppColors.lightSurface.withAlpha(26), // 0.1 opacity
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            title: Text(
              '${match["team1"]} vs ${match["team2"]}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.lightSurface,
              ),
            ),
            subtitle: Text(
              isUpcoming
                  ? 'Fecha: ${match["date"]}'
                  : 'Resultado: ${match["score"]}',
              style: const TextStyle(color: AppColors.secondaryAccent),
            ),
            onTap: () {
              // TODO: Navegar a la pantalla de detalles del partido
            },
          ),
        );
      },
    );
  }
}
