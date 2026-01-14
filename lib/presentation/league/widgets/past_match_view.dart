import 'package:fantasy_colegas_app/data/models/match.dart';
import 'package:fantasy_colegas_app/presentation/league/enter_match_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class PastMatchView extends StatelessWidget {
  final Match match;
  final bool isAdmin;

  const PastMatchView({
    super.key,
    required this.match,
    required this.isAdmin,
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
                  // Lógica para recargar la vista (ej. volver a llamar al provider o setState)
                }
              },
              icon: const Icon(Icons.add_chart),
              label: const Text('Introducir Resultados'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
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
    // TODO: Reemplazar esto con los datos reales de puntos por jugador
    final allPlayers = [...match.homeTeam.players, ...match.awayTeam.players];

    return ListView.builder(
      itemCount: allPlayers.length,
      itemBuilder: (context, index) {
        final player = allPlayers[index];
        return Card(
          color: AppColors.lightSurface.withAlpha(20),
          child: ListTile(
            title: Text(player.name, style: const TextStyle(color: AppColors.lightSurface)),
            trailing: const Text(
              '10 Pts', // Dato de ejemplo
              style: TextStyle(
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