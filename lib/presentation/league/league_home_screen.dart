import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/presentation/widgets/app_drawer.dart';
import 'tabs/home_tab_screen.dart';
import 'tabs/team_tab_screen.dart';
import 'tabs/standings_tab_screen.dart';
import 'tabs/players_tab_screen.dart';
import 'tabs/matches_tab_screen.dart';

class LeagueHomeScreen extends StatelessWidget {
  final League league;

  const LeagueHomeScreen({super.key, required this.league});

  @override
  Widget build(BuildContext context) {
    const tabTextStyle = TextStyle(fontSize: 11.5);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text(league.name),
          bottom: TabBar(
            tabAlignment: TabAlignment.fill,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            tabs: [
              const Tab(
                icon: Icon(Icons.home),
                child: Text('Inicio', style: tabTextStyle),
              ),
              const Tab(
                icon: Icon(Icons.person),
                child: Text('Equipo', style: tabTextStyle),
              ),
              const Tab(
                icon: Icon(Icons.leaderboard),
                child: Text('Clasificación', style: tabTextStyle, textAlign: TextAlign.center),
              ),
              const Tab(
                icon: Icon(Icons.run_circle),
                child: Text('Futbolistas', style: tabTextStyle, textAlign: TextAlign.center),
              ),
              const Tab(
                icon: Icon(Icons.sports_soccer),
                child: Text('Partidos', style: tabTextStyle),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomeTabScreen(league: league),
            TeamTabScreen(),
            StandingsTabScreen(),
            PlayersTabScreen(),
            MatchesTabScreen(),
          ],
        ),
      ),
    );
  }
}