import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';
import 'package:fantasy_colegas_app/data/models/user_score.dart';
import 'package:fantasy_colegas_app/domain/services/user_service.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';

class MemberInfoDialog extends StatefulWidget {
  final int leagueId;
  final User member;
  final bool isCurrentUserAdmin;
  final bool isMemberAdmin;
  final VoidCallback onDataChanged;

  const MemberInfoDialog({
    super.key,
    required this.leagueId,
    required this.member,
    required this.isCurrentUserAdmin,
    required this.isMemberAdmin,
    required this.onDataChanged,
  });

  @override
  State<MemberInfoDialog> createState() => _MemberInfoDialogState();
}

class _MemberInfoDialogState extends State<MemberInfoDialog> {
  final UserService _userService = UserService();
  final LeagueService _leagueService = LeagueService();

  late Future<List<UserScore>> _scoresFuture;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _scoresFuture = _userService.getUserLastScores(widget.leagueId, widget.member.id);
    _loadCurrentUserId();
  }

  // --- MÉTODO CORREGIDO ---
  // Usamos UserService para obtener el usuario actual y su ID.
  Future<void> _loadCurrentUserId() async {
    final currentUser = await _userService.getMe();
    if (mounted && currentUser != null) {
      setState(() {
        _currentUserId = currentUser.id;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _expelMember() async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Expulsar a ${widget.member.username}'),
          content: const Text('¿Estás seguro? Esta acción es irreversible.'),
          actions: [
            TextButton(child: const Text('Cancelar'), onPressed: () => navigator.pop(false)),
            TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Expulsar'), onPressed: () => navigator.pop(true)),
          ],
        ),
    );

    if (confirmed != true) return;

    final error = await _leagueService.expelUser(widget.leagueId, widget.member.id);
    if (error == null) {
      widget.onDataChanged();
      navigator.pop();
    } else {
      _showError(error);
    }
  }

  Future<void> _makeAdmin() async {
    final navigator = Navigator.of(context);
    final error = await _leagueService.makeUserAdmin(widget.leagueId, widget.member.id);
    if (error == null) {
      widget.onDataChanged();
      navigator.pop();
    } else {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.member.profileImageUrl != null && widget.member.profileImageUrl!.isNotEmpty;
    final fullImageUrl = hasImage ? '${ApiConfig.serverUrl}${widget.member.profileImageUrl}' : null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: hasImage
                ? NetworkImage(fullImageUrl!)
                : const AssetImage('assets/images/default_profile.png') as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text(widget.member.username, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          const Text('Últimas Puntuaciones', style: TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          _buildScoresList(),
        ],
      ),
      actions: [
        // La condición ahora usa la variable de estado _currentUserId
        if (widget.isCurrentUserAdmin && widget.member.id != _currentUserId)
          _buildAdminActions(),
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildScoresList() {
    return FutureBuilder<List<UserScore>>(
      future: _scoresFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(padding: EdgeInsets.all(8.0), child: Text('No hay datos de puntuación.'));
        }
        final scores = snapshot.data!;
        return Column(
          children: scores.map((score) => ListTile(
            trailing: Text('${score.totalPoints} pts', style: const TextStyle(fontWeight: FontWeight.bold)),
          )).toList(),
        );
      },
    );
  }

  Widget _buildAdminActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.gavel),
          label: const Text('Expulsar'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: _expelMember,
        ),
        if (!widget.isMemberAdmin)
          TextButton.icon(
            icon: const Icon(Icons.shield),
            label: const Text('Hacer Admin'),
            onPressed: _makeAdmin,
          ),
      ],
    );
  }
}
