import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart'; // <-- Importa el nuevo paquete

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
            backgroundColor: Colors.white.withAlpha(200),
            child: CircleAvatar(
              radius: 26,
              backgroundImage: hasImage
                  ? NetworkImage(playerImageUrl!)
                  : const AssetImage('assets/images/default_player.png') as ImageProvider,
            ),
          ),
          const SizedBox(height: 4),
          
          // --- ESTA ES LA SECCIÓN MODIFICADA ---
          // Contenedor que le da el fondo oscuro y los bordes redondeados al nombre
          Container(
            height: 20, // Altura fija para el contenedor del nombre
            width: 75,  // Ancho fijo para evitar que se expanda y cause overflow
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(180),
              borderRadius: BorderRadius.circular(10),
            ),
            // Usamos el widget Marquee en lugar de Text
            child: Marquee(
              text: playerName,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              scrollAxis: Axis.horizontal, // Dirección del scroll
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 10.0, // Espacio en blanco antes de que el texto se repita
              velocity: 10.0, // Velocidad del scroll
              pauseAfterRound: const Duration(seconds: 1), // Pausa antes de repetir
              startPadding: 10.0,
              accelerationDuration: const Duration(milliseconds: 500),
              accelerationCurve: Curves.ease,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          ),
          // --- FIN DE LA SECCIÓN MODIFICADA ---

          if (position != null) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: positionBackgroundColor ?? Colors.amber, 
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                position!,
                style: const TextStyle(
                  color: Colors.black,
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