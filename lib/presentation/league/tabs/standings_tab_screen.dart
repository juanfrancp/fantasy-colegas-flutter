import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/user_standings.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';

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
    const positionStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    
    final positionText = Container(
      alignment: Alignment.centerRight,
      child: Text('${index + 1}', style: positionStyle),
    );

    Widget medalWidget;
    
    switch (index) {
      case 0:
        medalWidget = Icon(Icons.emoji_events, color: Colors.amber[700]);
        break;
      case 1:
        medalWidget = Icon(Icons.emoji_events, color: Colors.grey[400]);
        break;
      case 2:
        medalWidget = Icon(Icons.emoji_events, color: Colors.brown[400]);
        break;
      default:
        medalWidget = const SizedBox(width: 24);
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        positionText,
        const SizedBox(width: 4),
        medalWidget,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<UserStandings>>(
        future: _standingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar la clasificación: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aún no hay datos para la clasificación.'));
          }

          final standings = snapshot.data!;

          return ListView.builder(
            itemCount: standings.length,
            itemBuilder: (context, index) {
              final userStanding = standings[index];
              final hasImage = userStanding.profileImageUrl != null && userStanding.profileImageUrl!.isNotEmpty;
              final fullImageUrl = hasImage ? '${ApiConfig.serverUrl}${userStanding.profileImageUrl}' : null;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: hasImage
                        ? NetworkImage(fullImageUrl!)
                        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                  ),
                  title: Row(
                    children: [
                      _getPlacementIcon(index),
                      const SizedBox(width: 8),
                      Text(userStanding.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: Text(
                    '${userStanding.totalPoints} pts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
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