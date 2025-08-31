import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class PlayerPositionWidget extends StatelessWidget {
  final String playerName;
  final String? playerImageUrl;
  final String? position;
  final Color? positionBackgroundColor;
  final VoidCallback onTap;

  const PlayerPositionWidget({
    super.key,
    required this.playerName,
    this.playerImageUrl,
    this.position,
    this.positionBackgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = playerImageUrl != null && playerImageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.pureWhite.withAlpha(200),
            child: CircleAvatar(
              radius: 26,
              backgroundImage: hasImage
                  ? NetworkImage(playerImageUrl!)
                  : const AssetImage('assets/images/default_player.png')
                        as ImageProvider,
            ),
          ),
          const SizedBox(height: 4),

          Container(
            height: 20,
            width: 75,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.darkBackground.withAlpha(180),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Marquee(
              text: playerName,
              style: const TextStyle(color: AppColors.pureWhite, fontSize: 12),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 10.0,
              velocity: 10.0,
              pauseAfterRound: const Duration(seconds: 1),
              startPadding: 10.0,
              accelerationDuration: const Duration(milliseconds: 500),
              accelerationCurve: Curves.ease,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          ),

          if (position != null) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: positionBackgroundColor ?? AppColors.secondaryAccent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                position!,
                style: const TextStyle(
                  color: AppColors.darkBackground,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
