import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/match.dart';
import 'package:fantasy_colegas_app/domain/services/match_service.dart'; // Importa el servicio
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';
import 'package:fantasy_colegas_app/presentation/league/widgets/past_match_view.dart';
import 'package:fantasy_colegas_app/presentation/league/widgets/upcoming_match_view.dart';

// CAMBIO 1: Ahora es StatefulWidget
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
  
  // Variable para guardar el estado actual del partido
  late Match _currentMatch;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos con los datos que nos pasan por parámetro
    _currentMatch = widget.match;
  }

  // ESTA ES LA FUNCIÓN QUE RECARGA LOS DATOS
  Future<void> _loadMatchDetails() async {
    setState(() => _isLoading = true);
    try {
      // Pedimos al backend el partido actualizado por ID
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isUpcoming ? 'Partido Programado' : 'Resultado del Partido'),
        backgroundColor: AppColors.primaryAccent,
        actions: [
          // Opción extra: Botón manual de recargar
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
                  match: _currentMatch, // Usamos _currentMatch, no widget.match
                  isAdmin: widget.isAdmin,
                  league: widget.league,
                )
              : PastMatchView(
                  match: _currentMatch, // Usamos _currentMatch
                  isAdmin: widget.isAdmin,
                  onMatchUpdated: () {
                    // Aquí llamamos a nuestra función
                    _loadMatchDetails(); 
                  },
                ),
    );
  }
}