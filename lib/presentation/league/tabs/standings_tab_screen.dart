import 'package:flutter/material.dart';

class StandingsTabScreen extends StatelessWidget {
  const StandingsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Clasificación\n(Próximamente)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}