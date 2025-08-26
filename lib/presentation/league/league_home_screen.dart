import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/presentation/widgets/app_drawer.dart';
import 'tabs/home_tab_screen.dart';
import 'tabs/team_tab_screen.dart';
import 'tabs/standings_tab_screen.dart';
import 'tabs/players_tab_screen.dart';
import 'tabs/matches_tab_screen.dart';

class LeagueHomeScreen extends StatefulWidget {
  final League initialLeague;

  const LeagueHomeScreen({super.key, required this.initialLeague});

  @override
  State<LeagueHomeScreen> createState() => _LeagueHomeScreenState();
}

class _LeagueHomeScreenState extends State<LeagueHomeScreen> {
  late League _currentLeague;
  final LeagueService _leagueService = LeagueService();

  @override
  void initState() {
    super.initState();
    _currentLeague = widget.initialLeague;
  }

  Future<void> _refreshLeagueData() async {
    final updatedLeague = await _leagueService.getLeagueById(_currentLeague.id);
    if (updatedLeague != null && mounted) {
      setState(() {
        _currentLeague = updatedLeague;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const tabTextStyle = TextStyle(fontSize: 11.5);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text(_currentLeague.name),
          bottom: const TabBar(
            tabAlignment: TabAlignment.fill,
            labelPadding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            tabs: [
              Tab(
                icon: Icon(Icons.home),
                child: Text('Inicio', style: tabTextStyle),
              ),
              Tab(
                icon: Icon(Icons.person),
                child: Text('Equipo', style: tabTextStyle),
              ),
              Tab(
                icon: Icon(Icons.leaderboard),
                child: Text('Clasificación', style: tabTextStyle, textAlign: TextAlign.center),
              ),
              Tab(
                icon: Icon(Icons.run_circle),
                child: Text('Futbolistas', style: tabTextStyle, textAlign: TextAlign.center),
              ),
              Tab(
                icon: Icon(Icons.sports_soccer),
                child: Text('Partidos', style: tabTextStyle),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomeTabScreen(league: _currentLeague, onLeagueUpdated: _refreshLeagueData),
            const TeamTabScreen(),
            const StandingsTabScreen(),
            const PlayersTabScreen(),
            const MatchesTabScreen(),
          ],
        ),
      ),
    );
  }
}