import 'package:flutter/material.dart';

class DeleteLeagueConfirmationDialog extends StatefulWidget {
  const DeleteLeagueConfirmationDialog({super.key});

  @override
  State<DeleteLeagueConfirmationDialog> createState() => _DeleteLeagueConfirmationDialogState();
}

class _DeleteLeagueConfirmationDialogState extends State<DeleteLeagueConfirmationDialog> {
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
      title: const Text('¿Estás seguro?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Esta acción es irreversible y borrará la liga, sus miembros y todos sus datos.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'Para confirmar, escribe ELIMINAR en el siguiente campo:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            decoration: const InputDecoration(
              hintText: 'ELIMINAR',
              border: OutlineInputBorder(),
            ),
            autocorrect: false,
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isButtonEnabled ? Colors.red : Colors.grey,
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