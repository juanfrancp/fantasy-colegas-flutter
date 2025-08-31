import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/match.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';
import 'package:fantasy_colegas_app/presentation/league/widgets/past_match_view.dart';
import 'package:fantasy_colegas_app/presentation/league/widgets/upcoming_match_view.dart';

class MatchDetailsScreen extends StatelessWidget {
  final Match match;
  final bool isAdmin;
  final bool isUpcoming; // <-- AÑADE ESTE PARÁMETRO
  final League league;

  const MatchDetailsScreen({
    super.key,
    required this.match,
    required this.isAdmin,
    required this.isUpcoming, // <-- AÑADE ESTO AL CONSTRUCTOR
    required this.league,
  });

  // ELIMINA ESTE GETTER
  // bool get isUpcoming => match.matchDate.isAfter(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Ahora usamos el parámetro que nos pasan
        title: Text(isUpcoming ? 'Partido Programado' : 'Resultado del Partido'),
        backgroundColor: AppColors.primaryAccent,
      ),
      backgroundColor: AppColors.darkBackground,
      // Y aquí también
      body: isUpcoming
          ? UpcomingMatchView(match: match, isAdmin: isAdmin, league: league,)
          : PastMatchView(match: match, isAdmin: isAdmin),
    );
  }
}