import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/match.dart'; // Importa el modelo Match
import 'package:fantasy_colegas_app/domain/services/match_service.dart'; // Importa el servicio
import 'package:fantasy_colegas_app/presentation/league/match_details_screen.dart';
import 'package:fantasy_colegas_app/presentation/league/schedule_match_screen.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';
import 'package:intl/intl.dart'; // Importa el paquete de formato de fecha

class MatchesTabScreen extends StatefulWidget {
  final League league;
  final bool isAdmin;

  const MatchesTabScreen({
    super.key,
    required this.league,
    this.isAdmin = false,
  });

  @override
  State<MatchesTabScreen> createState() => _MatchesTabScreenState();
}

class _MatchesTabScreenState extends State<MatchesTabScreen> {
  final MatchService _matchService = MatchService();

  bool _showUpcomingMatches = true;
  bool _isLoading = true;
  String? _errorMessage;

  // Listas para guardar los datos reales de la API
  List<Match> _upcomingMatches = [];
  List<Match> _pastMatches = [];

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Llamadas concurrentes para más eficiencia
      final results = await Future.wait([
        _matchService.getUpcomingMatches(widget.league.id),
        _matchService.getPastMatches(widget.league.id),
      ]);
      if (!mounted) return;

      setState(() {
        _upcomingMatches = results[0];
        _pastMatches = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al cargar los partidos: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Column(
        children: [
          _buildMatchToggleButtons(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchMatches,
                    child: _showUpcomingMatches
                        ? _buildMatchesList(_upcomingMatches, isUpcoming: true)
                        : _buildMatchesList(_pastMatches, isUpcoming: false),
                  ),
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) =>
                        ScheduleMatchScreen(league: widget.league),
                  ),
                );
                // Si se creó un partido con éxito, refrescamos la lista
                if (result == true) {
                  _fetchMatches();
                }
              },
              label: const Text('Programar Partido'),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.primaryAccent,
            )
          : null,
    );
  }

  Widget _buildMatchToggleButtons() {
    // ... (Este widget no necesita cambios, puedes dejar el que ya tienes)
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.lightSurface.withAlpha(26),
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

  // MÉTODO MODIFICADO PARA USAR EL MODELO Match
  Widget _buildMatchesList(List<Match> matches, {required bool isUpcoming}) {
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
        final formattedDate = DateFormat(
          'dd/MM/yyyy HH:mm',
        ).format(match.matchDate);
        final score = '${match.homeScore ?? '-'} - ${match.awayScore ?? '-'}';

        return Card(
          color: AppColors.lightSurface.withAlpha(26),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            title: Text(
              '${match.homeTeam.name} vs ${match.awayTeam.name}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.lightSurface,
              ),
            ),
            subtitle: Text(
              isUpcoming ? 'Fecha: $formattedDate' : 'Resultado: $score',
              style: const TextStyle(color: AppColors.secondaryAccent),
            ),
            onTap: () async {
              final bool? shouldRefresh = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => MatchDetailsScreen(
                    match: match,
                    isAdmin: widget.isAdmin,
                    isUpcoming: isUpcoming,
                    league: widget.league,
                  ),
                ),
              );
              if (shouldRefresh == true) {
                _fetchMatches();
              }
            },
          ),
        );
      },
    );
  }
}
