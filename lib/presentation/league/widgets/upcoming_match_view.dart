import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/match.dart';
import 'package:fantasy_colegas_app/presentation/league/edit_match_screen.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';
import 'package:intl/intl.dart';

class UpcomingMatchView extends StatelessWidget {
  final Match match;
  final bool isAdmin;
  final League league;

  const UpcomingMatchView({
    super.key,
    required this.match,
    required this.isAdmin,
    required this.league,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildTeamPlayerList('Equipo Local: ${match.homeTeam.name}', match.homeTeam.players),
          const SizedBox(height: 24),
          _buildTeamPlayerList('Equipo Visitante: ${match.awayTeam.name}', match.awayTeam.players),
          const SizedBox(height: 32),
          if (isAdmin)
            ElevatedButton.icon(
              onPressed: () async {
                final bool? refreshNeeded = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => EditMatchScreen(
                      match: match,
                      league: league,
                    ),
                  ),
                );
                if (refreshNeeded == true && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Modificar Partido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          '${match.homeTeam.name} vs ${match.awayTeam.name}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.lightSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE, d MMMM y, HH:mm', 'es_ES').format(match.matchDate),
          style: const TextStyle(
            color: AppColors.secondaryAccent,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamPlayerList(String title, List<dynamic> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.lightSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...players.map((player) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Text(
            '- ${player.name}',
            style: const TextStyle(color: AppColors.lightSurface, fontSize: 16),
          ),
        )),
      ],
    );
  }
}