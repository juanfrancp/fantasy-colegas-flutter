import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/domain/services/player_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/presentation/league/edit_player_screen.dart';

class PlayerInfoDialog extends StatelessWidget {
  final int leagueId;
  final Player player;
  final bool isAdmin;
  final VoidCallback onDataChanged;

  const PlayerInfoDialog({
    super.key,
    required this.leagueId,
    required this.player,
    required this.isAdmin,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final PlayerService playerService = PlayerService();
    final navigator = Navigator.of(context);

  void deletePlayer() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Seguro que quieres eliminar a ${player.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await playerService.deletePlayer(leagueId, player.id);
      
      messenger.showSnackBar(const SnackBar(content: Text('Jugador eliminado.'), backgroundColor: Colors.green));
      navigator.pop();
      onDataChanged();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al eliminar: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red)
      );
    }
  }

    void editPlayer() async {
      navigator.pop();
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => EditPlayerScreen(leagueId: leagueId, player: player),
        ),
      );
      if (result == true) {
        onDataChanged();
      }
    }

    final hasImage = player.image != null && player.image!.isNotEmpty;
    final fullImageUrl = hasImage ? '${ApiConfig.serverUrl}${player.image}' : null;

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
                : const AssetImage('assets/images/default_player.png') as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text(player.name, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            '${player.totalPoints} Puntos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      actions: [
        if (isAdmin)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: deletePlayer,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
              TextButton.icon(
                onPressed: editPlayer,
                icon: const Icon(Icons.edit),
                label: const Text('Modificar'),
              ),
            ],
          ),
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () => navigator.pop(),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}