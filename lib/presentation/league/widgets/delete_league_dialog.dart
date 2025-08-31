import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class DeleteLeagueConfirmationDialog extends StatefulWidget {
  const DeleteLeagueConfirmationDialog({super.key});

  @override
  State<DeleteLeagueConfirmationDialog> createState() =>
      _DeleteLeagueConfirmationDialogState();
}

class _DeleteLeagueConfirmationDialogState
    extends State<DeleteLeagueConfirmationDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(() {
      setState(() {
        _isButtonEnabled = _confirmationController.text == 'ELIMINAR';
      });
    });
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkBackground,
      title: const Text(
        '¿Estás seguro?',
        style: TextStyle(color: AppColors.lightSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Esta acción es irreversible y borrará la liga, sus miembros y todos sus datos.',
            style: TextStyle(fontSize: 14, color: AppColors.lightSurface),
          ),
          const SizedBox(height: 16),
          const Text(
            'Para confirmar, escribe ELIMINAR en el siguiente campo:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.lightSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            style: const TextStyle(color: AppColors.lightSurface),
            decoration: InputDecoration(
              hintText: 'ELIMINAR',
              hintStyle: TextStyle(
                color: AppColors.lightSurface.withAlpha(150),
              ),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.secondaryAccent.withAlpha(100),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.lightSurface),
              ),
            ),
            autocorrect: false,
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.secondaryAccent),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isButtonEnabled
                ? AppColors.primaryAccent
                : Colors.grey,
            foregroundColor: AppColors.pureWhite,
          ),
          onPressed: _isButtonEnabled
              ? () => Navigator.of(context).pop(true)
              : null,
          child: const Text('Eliminar Definitivamente'),
        ),
      ],
    );
  }
}
