class PlayerMatchStatsUpdate {
  final int playerId;
  final int golesMarcados;
  final int asistencias;
  final int tarjetasAmarillas;
  final int tarjetasRojas;
  final int tiempoJugado;
  // Añade aquí el resto de campos que tienes en el Java DTO (pases, tiros, etc.)

  PlayerMatchStatsUpdate({
    required this.playerId,
    this.golesMarcados = 0,
    this.asistencias = 0,
    this.tarjetasAmarillas = 0,
    this.tarjetasRojas = 0,
    this.tiempoJugado = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'golesMarcados': golesMarcados,
      'asistencias': asistencias,
      'tarjetasAmarillas': tarjetasAmarillas,
      'tarjetasRojas': tarjetasRojas,
      'tiempoJugado': tiempoJugado,
      // Mapea el resto
    };
  }
}