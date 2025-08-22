import 'package:flutter/material.dart';

class TeamTabScreen extends StatelessWidget {
  const TeamTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Mi Equipo\n(Próximamente)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}