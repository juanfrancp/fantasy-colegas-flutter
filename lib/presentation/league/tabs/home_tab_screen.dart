import 'package:fantasy_colegas_app/data/models/user.dart';
import 'package:fantasy_colegas_app/presentation/league/tabs/widgets/join_requests_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/domain/services/user_service.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'widgets/member_info_dialog.dart';

class HomeTabScreen extends StatefulWidget {
  final League league;
  const HomeTabScreen({super.key, required this.league});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  final LeagueService _leagueService = LeagueService();
  final UserService _userService = UserService();
  late Future<List<User>> _membersFuture;

  bool _isAdmin = false;
  int _pendingRequestsCount = 0;

  @override
  void initState() {
    super.initState();
    _checkAdminStatusAndLoadData();
    _membersFuture = _leagueService.getLeagueMembers(widget.league.id);
  }

  Future<void> _checkAdminStatusAndLoadData() async {
    final currentUser = await _userService.getMe();
    if (currentUser == null) return;

    final isAdmin = widget.league.admins.any(
      (admin) => admin.id == currentUser.id,
    );

    if (isAdmin) {
      final count = await _leagueService.getPendingJoinRequestsCount(
        widget.league.id,
      );
      if (mounted) {
        setState(() {
          _isAdmin = true;
          _pendingRequestsCount = count;
        });
      }
    }
  }

  void _showJoinRequestsDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => JoinRequestsDialog(leagueId: widget.league.id),
    );

    // Si el diálogo devuelve 'true', significa que se aceptó o rechazó a alguien
    if (result == true && mounted) {
      // Recargamos tanto el contador de solicitudes como la lista de miembros
      _checkAdminStatusAndLoadData();
      setState(() {
         _membersFuture = _leagueService.getLeagueMembers(widget.league.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final league = widget.league;
    final hasImage = league.image != null && league.image!.isNotEmpty;
    final fullImageUrl = hasImage
        ? '${ApiConfig.serverUrl}${league.image}'
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- SECCIÓN DE BOTONES DE ADMIN MODIFICADA ---
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                // 1. Centramos los botones
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRequestsButton(), // Este widget ahora devuelve un TextButton.icon
                  const SizedBox(width: 16),
                  // 2. Reemplazamos IconButton por TextButton.icon
                  TextButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text('Gestionar'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Próximamente: Gestionar Liga'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          // --- El resto de la UI no cambia ---
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            // Reemplazamos backgroundImage por child para más control.
            child: ClipOval(
              child: hasImage
                  ? Image.network(
                      fullImageUrl!,
                      width: 120, // diámetro
                      height: 120, // diámetro
                      fit: BoxFit.cover,
                      // Manejador por si la URL falla
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/default_league.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      // Caso para ligas sin imagen
                      'assets/images/default_league.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            league.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            league.description ?? 'Esta liga no tiene descripción.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Miembros',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // --- NUEVA SECCIÓN: LISTA DE MIEMBROS ---
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
              // Usamos ListView.separated para añadir divisores entre los miembros
              return ListView.separated(
                physics:
                    const NeverScrollableScrollPhysics(), // Para que no haga scroll dentro del SingleChildScrollView
                shrinkWrap: true, // Para que ocupe solo el espacio necesario
                itemCount: members.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final member = members[index];
                  final hasImage =
                      member.profileImageUrl != null &&
                      member.profileImageUrl!.isNotEmpty;
                  final fullImageUrl = hasImage
                      ? '${ApiConfig.serverUrl}${member.profileImageUrl}'
                      : null;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: hasImage
                          ? NetworkImage(fullImageUrl!)
                          : const AssetImage(
                                  'assets/images/default_profile.png',
                                )
                                as ImageProvider,
                      onBackgroundImageError: hasImage ? (_, __) {} : null,
                    ),
                    title: Text(member.username),
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
        ],
      ),
    );
  }

  // --- WIDGET DEL BOTÓN DE SOLICITUDES MODIFICADO ---
  Widget _buildRequestsButton() {
    String countText = '$_pendingRequestsCount';
    if (_pendingRequestsCount > 99) {
      countText = '+99';
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 3. Reemplazamos IconButton por TextButton.icon
        TextButton.icon(
          icon: const Icon(Icons.email_outlined),
          label: const Text('Solicitudes'),
          onPressed: _showJoinRequestsDialog,
        ),
        if (_pendingRequestsCount > 0)
          Positioned(
            // 4. Ajustamos la posición del contador
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
