import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/presentation/league/league_home_screen.dart';
import 'package:fantasy_colegas_app/domain/services/auth_service.dart';
import 'package:fantasy_colegas_app/domain/services/user_service.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';
import 'package:fantasy_colegas_app/presentation/auth/login_screen.dart';
import 'package:fantasy_colegas_app/presentation/profile/profile_screen.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/presentation/league/join_league_screen.dart';
import 'package:fantasy_colegas_app/presentation/league/create_league_screen.dart';

class AppDrawer extends StatefulWidget {
  final VoidCallback? onLeaguesChanged;

  const AppDrawer({super.key, this.onLeaguesChanged});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late Future<List<League>> _leaguesFuture;
  late Future<User?> _userFuture;
  final LeagueService _leagueService = LeagueService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _leaguesFuture = _leagueService.getMyLeagues();
    _userFuture = _userService.getMe();
  }


  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToProfile() async {
    Navigator.pop(context);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
    setState(() {
      _userFuture = _userService.getMe();
    });
  }

  void _navigateToLeague(League league) {
    Navigator.pop(context);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LeagueHomeScreen(initialLeague: league),
      ),
    );
  }

  void _navigateToCreateLeagueScreen() async {
    final callback = widget.onLeaguesChanged;

    Navigator.pop(context);

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const CreateLeagueScreen()),
    );
    if (result == true) {
      callback?.call();
      if (mounted) {
        setState(() {
          _leaguesFuture = _leagueService.getMyLeagues();
        });
      }
    }
  }

  void _navigateToJoinLeagueScreen() async {
    final callback = widget.onLeaguesChanged;

    Navigator.pop(context);

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const JoinLeagueScreen()),
    );
    if (result == true) {
      callback?.call();
      if (mounted) {
        setState(() {
          _leaguesFuture = _leagueService.getMyLeagues();
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<User?>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.deepPurple),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                final user = snapshot.data!;
                final hasImage = user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty;
                return UserAccountsDrawerHeader(
                  accountName: Text(user.username),
                  accountEmail: null,
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: hasImage
                        ? NetworkImage(ApiConfig.serverUrl + user.profileImageUrl!)
                        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                    backgroundColor: Colors.white,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                  ),
                );
              } else {
                return const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.deepPurple),
                  child: Text('Error al cargar perfil', style: TextStyle(color: Colors.white)),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modificar perfil'),
            onTap: _navigateToProfile,
          ),
          const Divider(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Mis Ligas', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          FutureBuilder<List<League>>(
            future: _leaguesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Column(
                  children: snapshot.data!.map((league) {
                    final hasCustomImage = league.image != null && league.image!.isNotEmpty;
                    final fullImageUrl = hasCustomImage ? '${ApiConfig.serverUrl}${league.image}' : null;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: hasCustomImage
                            ? Image.network(
                                fullImageUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/default_league.png',
                                    width: 40, height: 40, fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/default_league.png',
                                width: 40, height: 40, fit: BoxFit.cover,
                              ),
                        ),
                      ),
                      title: Text(league.name),
                      onTap: () => _navigateToLeague(league),
                    );
                  }).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Únete a una liga'),
            onTap: _navigateToJoinLeagueScreen,
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Crea una liga'),
            onTap: _navigateToCreateLeagueScreen,
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.email_rounded),
            title: const Text('Envia tus comentarios.'),
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }
}