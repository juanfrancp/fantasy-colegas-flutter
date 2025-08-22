import 'package:flutter/material.dart';

class MatchesTabScreen extends StatelessWidget {
  const MatchesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Partidos\n(Próximamente)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}