import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/domain/services/player_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/presentation/league/edit_player_screen.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

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
          backgroundColor: AppColors.darkBackground,
          title: const Text(
            'Confirmar eliminación',
            style: TextStyle(color: AppColors.lightSurface),
          ),
          content: Text(
            '¿Seguro que quieres eliminar a ${player.name}?',
            style: const TextStyle(color: AppColors.lightSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.secondaryAccent),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.primaryAccent),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      try {
        await playerService.deletePlayer(leagueId, player.id);

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Jugador eliminado.'),
            backgroundColor: AppColors.secondaryAccent,
          ),
        );
        navigator.pop();
        onDataChanged();
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Error al eliminar: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
            backgroundColor: AppColors.primaryAccent,
          ),
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
    final fullImageUrl = hasImage
        ? '${ApiConfig.serverUrl}${player.image}'
        : null;

    return AlertDialog(
      backgroundColor: AppColors.darkBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.lightSurface,
            backgroundImage: hasImage
                ? NetworkImage(fullImageUrl!)
                : const AssetImage('assets/images/default_player.png')
                      as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text(
            player.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.lightSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${player.totalPoints} Puntos',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryAccent,
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
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryAccent,
                ),
              ),
              TextButton.icon(
                onPressed: editPlayer,
                icon: const Icon(Icons.edit),
                label: const Text('Modificar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondaryAccent,
                ),
              ),
            ],
          ),
        TextButton(
          child: const Text(
            'Cerrar',
            style: TextStyle(color: AppColors.secondaryAccent),
          ),
          onPressed: () => navigator.pop(),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
