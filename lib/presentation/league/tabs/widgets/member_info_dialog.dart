import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';

class MemberInfoDialog extends StatelessWidget {
  final User member;

  const MemberInfoDialog({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final hasImage = member.profileImageUrl != null && member.profileImageUrl!.isNotEmpty;
    final fullImageUrl = hasImage ? '${ApiConfig.serverUrl}${member.profileImageUrl}' : null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: hasImage
                ? NetworkImage(fullImageUrl!)
                : const AssetImage('assets/images/default_profile.png') as ImageProvider,
            onBackgroundImageError: hasImage ? (_, __) {} : null,
          ),
          const SizedBox(height: 16),
          Text(
            member.username,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          // Aquí puedes añadir más información en el futuro (puntos, etc.)
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}