import 'package:flutter/material.dart';

class PlayersTabScreen extends StatelessWidget {
  const PlayersTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Futbolistas\n(Próximamente)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}