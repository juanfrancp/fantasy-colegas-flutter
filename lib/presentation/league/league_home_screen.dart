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
    // Para que el texto se vea bien, definimos un estilo común.
    const tabTextStyle = TextStyle(fontSize: 11.5);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text(league.name),
          bottom: TabBar(
            tabAlignment: TabAlignment.fill,
            // Usamos labelPadding para dar un poco de espacio vertical.
            labelPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            tabs: [
              // --- CAMBIO PRINCIPAL AQUÍ ---
              // Reemplazamos 'text' por 'child' para tener más control.
              const Tab(
                icon: Icon(Icons.home),
                child: Text('Inicio', style: tabTextStyle),
              ),
              const Tab(
                icon: Icon(Icons.person),
                child: Text('Equipo', style: tabTextStyle),
              ),
              // En los textos largos, el widget Text se encargará de hacer el salto de línea.
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
        body: const TabBarView(
          children: [
            HomeTabScreen(),
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