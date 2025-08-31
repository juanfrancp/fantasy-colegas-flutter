import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/user_standings.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class StandingsTabScreen extends StatefulWidget {
  final League league;

  const StandingsTabScreen({super.key, required this.league});

  @override
  State<StandingsTabScreen> createState() => _StandingsTabScreenState();
}

class _StandingsTabScreenState extends State<StandingsTabScreen> {
  final LeagueService _leagueService = LeagueService();
  late Future<List<UserStandings>> _standingsFuture;

  @override
  void initState() {
    super.initState();
    _standingsFuture = _leagueService.getLeagueStandings(widget.league.id);
  }

  Widget _getPlacementIcon(int index) {
    const positionStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: AppColors.lightSurface,
    );

    final positionText = Container(
      alignment: Alignment.centerRight,
      child: Text('${index + 1}', style: positionStyle),
    );

    Widget medalWidget;

    if (index == 0) {
      medalWidget = const Icon(
        Icons.emoji_events,
        color: AppColors.secondaryAccent,
      );
    } else {
      medalWidget = const SizedBox(width: 24);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [positionText, const SizedBox(width: 4), medalWidget],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: FutureBuilder<List<UserStandings>>(
        future: _standingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAccent),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar la clasificación: ${snapshot.error}',
                style: const TextStyle(color: AppColors.primaryAccent),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aún no hay datos para la clasificación.',
                style: TextStyle(color: AppColors.lightSurface),
              ),
            );
          }

          final standings = snapshot.data!;

          return ListView.separated(
            itemCount: standings.length,
            separatorBuilder: (context, index) => const Divider(
              color: AppColors.secondaryAccent,
              height: 1,
              indent: 72,
            ),
            itemBuilder: (context, index) {
              final userStanding = standings[index];
              final hasImage =
                  userStanding.profileImageUrl != null &&
                  userStanding.profileImageUrl!.isNotEmpty;
              final fullImageUrl = hasImage
                  ? '${ApiConfig.serverUrl}${userStanding.profileImageUrl}'
                  : null;

              return ListTile(
                tileColor: AppColors.darkBackground,
                leading: CircleAvatar(
                  backgroundColor: AppColors.lightSurface,
                  backgroundImage: hasImage
                      ? NetworkImage(fullImageUrl!)
                      : const AssetImage('assets/images/default_profile.png')
                            as ImageProvider,
                ),
                title: Row(
                  children: [
                    _getPlacementIcon(index),
                    const SizedBox(width: 8),
                    Text(
                      userStanding.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightSurface,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  '${userStanding.totalPoints} pts',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryAccent,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
