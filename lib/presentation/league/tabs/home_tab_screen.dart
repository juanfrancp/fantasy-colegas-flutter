import 'package:fantasy_colegas_app/presentation/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';
import 'package:fantasy_colegas_app/domain/services/user_service.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/presentation/league/manage_league_screen.dart';
import 'widgets/join_requests_dialog.dart';
import 'widgets/member_info_dialog.dart';

class HomeTabScreen extends StatefulWidget {
  final League league;
  final VoidCallback onLeagueUpdated;

  const HomeTabScreen({
    super.key,
    required this.league,
    required this.onLeagueUpdated,
  });

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  final LeagueService _leagueService = LeagueService();
  final UserService _userService = UserService();

  bool _isAdmin = false;
  int _pendingRequestsCount = 0;
  late Future<List<User>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _loadAllDataForLeague();
  }

  @override
  void didUpdateWidget(HomeTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.league != oldWidget.league) {
      _loadAllDataForLeague();
    }
  }

  void _loadAllDataForLeague() {
    _checkAdminStatusAndLoadData();
    setState(() {
      _membersFuture = _leagueService.getLeagueMembers(widget.league.id);
    });
  }

  Future<void> _checkAdminStatusAndLoadData() async {
    final currentUser = await _userService.getMe();
    if (currentUser == null || !mounted) return;

    final isAdmin = widget.league.admins.any((admin) => admin.id == currentUser.id);
    
    if (isAdmin) {
      final count = await _leagueService.getPendingJoinRequestsCount(widget.league.id);
      if (mounted) {
        setState(() {
          _isAdmin = true;
          _pendingRequestsCount = count;
        });
      }
    } else if (mounted) {
      setState(() {
        _isAdmin = false;
        _pendingRequestsCount = 0;
      });
    }
  }

  void _showJoinRequestsDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => JoinRequestsDialog(leagueId: widget.league.id),
    );

    if (result == true && mounted) {
      _loadAllDataForLeague();
    }
  }

  Future<void> _leaveLeague() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonar Liga'),
        content: const Text('¿Estás seguro de que quieres abandonar esta liga? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Abandonar'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final errorMessage = await _leagueService.leaveLeague(widget.league.id);

    if (!mounted) return;

    if (errorMessage == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Has abandonado la liga.'), backgroundColor: Colors.green),
      );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final league = widget.league;
    final hasImage = league.image != null && league.image!.isNotEmpty;
    final fullImageUrl = hasImage ? '${ApiConfig.serverUrl}${league.image}' : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRequestsButton(),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text('Gestionar'),
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ManageLeagueScreen(league: widget.league),
                        ),
                      );
                      if (result == true) {
                        widget.onLeagueUpdated();
                      }
                    },
                  ),
                ],
              ),
            ),
          
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: hasImage
                ? Image.network(
                    fullImageUrl!,
                    width: 120, height: 120, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Image.asset('assets/images/default_league.png', width: 120, height: 120, fit: BoxFit.cover),
                  )
                : Image.asset('assets/images/default_league.png', width: 120, height: 120, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            league.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          
          if (league.joinCode != null && league.joinCode!.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: league.joinCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Código copiado al portapapeles!')),
                );
              },
              child: Tooltip(
                message: 'Toca para copiar',
                child: Chip(
                  avatar: const Icon(Icons.content_copy, size: 16),
                  label: Text(
                    league.joinCode!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),
          Text(
            league.description ?? 'Esta liga no tiene descripción.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text('Miembros', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          
          FutureBuilder<List<User>>(
            future: _membersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Text('Error al cargar los miembros.');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No hay miembros en esta liga.');
              }

              final members = snapshot.data!;
              return ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: members.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final member = members[index];
                  final hasMemberImage = member.profileImageUrl != null && member.profileImageUrl!.isNotEmpty;
                  final fullMemberImageUrl = hasMemberImage ? '${ApiConfig.serverUrl}${member.profileImageUrl}' : null;
                  
                  final bool isMemberAdmin = widget.league.admins.any((admin) => admin.id == member.id);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: hasMemberImage
                          ? NetworkImage(fullMemberImageUrl!)
                          : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                    ),
                    title: Text(member.username),
                    trailing: isMemberAdmin
                        ? Tooltip(
                            message: 'Administrador',
                            child: Icon(Icons.shield, color: Theme.of(context).primaryColor),
                          )
                        : null,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => MemberInfoDialog(member: member),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: _leaveLeague,
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Abandonar Liga'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsButton() {
    String countText = '$_pendingRequestsCount';
    if (_pendingRequestsCount > 99) {
      countText = '+99';
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.email_outlined),
          label: const Text('Solicitudes'),
          onPressed: _showJoinRequestsDialog,
        ),
        if (_pendingRequestsCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                countText,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}