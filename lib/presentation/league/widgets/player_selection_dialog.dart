import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class PlayerSelectionDialog extends StatefulWidget {
  final List<Player> allPlayers;
  final List<Player> initiallySelectedPlayers;

  const PlayerSelectionDialog({
    super.key,
    required this.allPlayers,
    required this.initiallySelectedPlayers,
  });

  @override
  State<PlayerSelectionDialog> createState() => _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState extends State<PlayerSelectionDialog> {
  late Set<Player> _selectedPlayers;

  @override
  void initState() {
    super.initState();
    _selectedPlayers = widget.initiallySelectedPlayers.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkBackground,
      title: const Text(
        'Seleccionar Jugadores',
        style: TextStyle(color: AppColors.lightSurface),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: widget.allPlayers.length,
          itemBuilder: (context, index) {
            final player = widget.allPlayers[index];
            final isSelected = _selectedPlayers.contains(player);
            return CheckboxListTile(
              title: Text(
                player.name,
                style: const TextStyle(color: AppColors.lightSurface),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedPlayers.add(player);
                  } else {
                    _selectedPlayers.remove(player);
                  }
                });
              },
              activeColor: AppColors.secondaryAccent,
              checkColor: AppColors.darkBackground,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.lightSurface),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedPlayers.toList());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
          ),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
