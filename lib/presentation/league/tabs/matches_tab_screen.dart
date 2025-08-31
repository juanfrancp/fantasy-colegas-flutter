import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class MatchesTabScreen extends StatelessWidget {
  const MatchesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Text(
          'Partidos\n(Próximamente)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: AppColors.lightSurface),
        ),
      ),
    );
  }
}