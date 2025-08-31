import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/domain/services/user_service.dart';
import 'package:fantasy_colegas_app/presentation/widgets/app_drawer.dart';
import 'tabs/home_tab_screen.dart';
import 'tabs/team_tab_screen.dart';
import 'tabs/standings_tab_screen.dart';
import 'tabs/players_tab_screen.dart';
import 'tabs/matches_tab_screen.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class LeagueHomeScreen extends StatefulWidget {
  final League initialLeague;

  const LeagueHomeScreen({super.key, required this.initialLeague});

  @override
  State<LeagueHomeScreen> createState() => _LeagueHomeScreenState();
}

class _LeagueHomeScreenState extends State<LeagueHomeScreen> {
  late League _currentLeague;
  final LeagueService _leagueService = LeagueService();
  final UserService _userService = UserService();

  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _currentLeague = widget.initialLeague;
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final currentUser = await _userService.getMe();
      if (!mounted) return;
      final isAdmin = _currentLeague.admins.any(
        (admin) => admin.id == currentUser.id,
      );
      setState(() {
        _isAdmin = isAdmin;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAdmin = false;
        });
      }
    }
  }

  Future<void> _refreshLeagueData() async {
    try {
      final updatedLeague = await _leagueService.getLeagueById(
        _currentLeague.id,
      );

      if (mounted) {
        setState(() {
          _currentLeague = updatedLeague;
        });
        await _checkAdminStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al actualizar la liga: ${e.toString().replaceFirst("Exception: ", "")}',
              style: const TextStyle(color: AppColors.pureWhite),
            ),
            backgroundColor: AppColors.primaryAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text(
            _currentLeague.name,
            style: const TextStyle(color: AppColors.lightSurface),
          ),
          backgroundColor: AppColors.darkBackground,
          iconTheme: const IconThemeData(color: AppColors.lightSurface),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            labelPadding: EdgeInsets.symmetric(horizontal: 12.0),
            indicatorColor: AppColors.primaryAccent,
            labelColor: AppColors.primaryAccent,
            unselectedLabelColor: AppColors.lightSurface,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Inicio'),
              Tab(icon: Icon(Icons.person), text: 'Equipo'),
              Tab(icon: Icon(Icons.leaderboard), text: 'Clasificación'),
              Tab(icon: Icon(Icons.run_circle), text: 'Futbolistas'),
              Tab(icon: Icon(Icons.sports_soccer), text: 'Partidos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomeTabScreen(
              league: _currentLeague,
              onLeagueUpdated: _refreshLeagueData,
              isAdmin: _isAdmin,
            ),
            TeamTabScreen(league: _currentLeague),
            StandingsTabScreen(league: _currentLeague),
            PlayersTabScreen(league: _currentLeague, isAdmin: _isAdmin),
            const MatchesTabScreen(),
          ],
        ),
      ),
    );
  }
}
