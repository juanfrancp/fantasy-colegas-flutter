import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/match.dart';
import 'package:fantasy_colegas_app/domain/services/match_service.dart';
import 'package:fantasy_colegas_app/presentation/league/enter_match_results_screen.dart'; // <--- IMPORTA ESTO
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';
import 'package:fantasy_colegas_app/presentation/league/widgets/past_match_view.dart';
import 'package:fantasy_colegas_app/presentation/league/widgets/upcoming_match_view.dart';

class MatchDetailsScreen extends StatefulWidget {
  final Match match;
  final bool isAdmin;
  final bool isUpcoming;
  final League league;

  const MatchDetailsScreen({
    super.key,
    required this.match,
    required this.isAdmin,
    required this.isUpcoming,
    required this.league,
  });

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final MatchService _matchService = MatchService();
  
  late Match _currentMatch;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentMatch = widget.match;
  }

  Future<void> _loadMatchDetails() async {
    setState(() => _isLoading = true);
    try {
      final updatedMatch = await _matchService.getMatch(_currentMatch.id);
      
      if (mounted) {
        setState(() {
          _currentMatch = updatedMatch;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  // Función para navegar a la edición de resultados
  Future<void> _navigateToEditResults() async {
    final bool? resultUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnterMatchResultsScreen(match: _currentMatch),
      ),
    );

    // Si devuelve true, significa que se guardaron cambios -> recargamos
    if (resultUpdated == true) {
      _loadMatchDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isUpcoming ? 'Partido Programado' : 'Resultado del Partido'),
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.pureWhite, // Asegura contraste
        actions: [
          // --- BOTÓN DE MODIFICAR RESULTADO (Solo Admins y Partidos Pasados) ---
          if (widget.isAdmin && !widget.isUpcoming)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Modificar Resultado',
              onPressed: _navigateToEditResults,
            ),
            
          // Botón manual de recargar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatchDetails,
          )
        ],
      ),
      backgroundColor: AppColors.darkBackground,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : widget.isUpcoming
              ? UpcomingMatchView(
                  match: _currentMatch,
                  isAdmin: widget.isAdmin,
                  league: widget.league,
                )
              : PastMatchView(
                  match: _currentMatch,
                  isAdmin: widget.isAdmin,
                  onMatchUpdated: () {
                    _loadMatchDetails(); 
                  },
                ),
    );
  }
}