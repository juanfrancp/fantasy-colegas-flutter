import 'package:fantasy_colegas_app/data/models/match.dart';
import 'package:fantasy_colegas_app/presentation/league/enter_match_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class PastMatchView extends StatelessWidget {
  final Match match;
  final bool isAdmin;
  final VoidCallback onMatchUpdated;

  const PastMatchView({
    super.key,
    required this.match,
    required this.isAdmin,
    required this.onMatchUpdated,
  });

  // Determina si el partido tiene resultados introducidos
  bool get _hasResults => match.homeScore != null && match.awayScore != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildScoreHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: _hasResults ? _buildResultsList() : _buildNoResultsMessage(),
          ),
          if (isAdmin && !_hasResults)
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnterMatchResultsScreen(match: match),
                  ),
                );
                
                // Si devuelve true, es que se guardaron datos, recarga la pantalla si es necesario
                if (result == true) {
                  onMatchUpdated();
                }
              },
              icon: const Icon(Icons.add_chart),
              label: const Text('Introducir Resultados'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: AppColors.pureWhite,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader() {
    return Text(
      '${match.homeTeam.name}  ${match.homeScore ?? '-'} : ${match.awayScore ?? '-'}  ${match.awayTeam.name}',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.lightSurface,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return const Center(
      child: Text(
        'Los resultados y las estadísticas estarán disponibles próximamente.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.secondaryAccent,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    final allPlayers = [...match.homeTeam.players, ...match.awayTeam.players];

    return ListView.builder(
      itemCount: allPlayers.length,
      itemBuilder: (context, index) {
        final player = allPlayers[index];
        // Formatear puntos para quitar decimales .0 si es entero
        String pointsText = player.totalPoints % 1 == 0 
            ? player.totalPoints.toInt().toString() 
            : player.totalPoints.toStringAsFixed(1);

        return Card(
          color: AppColors.lightSurface.withValues(alpha: 0.1), // Usando sintaxis nueva
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.secondaryAccent,
              child: Text(player.name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(player.name, style: const TextStyle(color: AppColors.lightSurface)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryAccent),
              ),
              child: Text(
                '$pointsText Pts', // <--- 3. DATO REAL
                style: const TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}