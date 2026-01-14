class PlayerMatchStatsUpdate {
  final int playerId;
  // Campos básicos
  final int golesMarcados;
  final int asistencias;
  final int tarjetasAmarillas;
  final int tarjetasRojas;
  
  // Campos de Campo
  final int fallosClarosDeGol;
  final int faltasCometidas;
  final int faltasRecibidas;
  final int penaltisCometidos;
  final int penaltisRecibidos;
  final int salvadasDeGol; // NUEVO

  // Campos de Portero
  final int golesEncajadosComoPortero;
  final int paradasComoPortero;
  final int penaltisParados; // NUEVO
  final bool porteriaImbatida; // NUEVO (Bonus Clean Sheet)

  PlayerMatchStatsUpdate({
    required this.playerId,
    this.golesMarcados = 0,
    this.asistencias = 0,
    this.tarjetasAmarillas = 0,
    this.tarjetasRojas = 0,
    this.fallosClarosDeGol = 0,
    this.faltasCometidas = 0,
    this.faltasRecibidas = 0,
    this.penaltisCometidos = 0,
    this.penaltisRecibidos = 0,
    this.salvadasDeGol = 0,
    this.golesEncajadosComoPortero = 0,
    this.paradasComoPortero = 0,
    this.penaltisParados = 0,
    this.porteriaImbatida = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'golesMarcados': golesMarcados,
      'asistencias': asistencias,
      'tarjetasAmarillas': tarjetasAmarillas,
      'tarjetasRojas': tarjetasRojas,
      'fallosClarosDeGol': fallosClarosDeGol,
      'faltasCometidas': faltasCometidas,
      'faltasRecibidas': faltasRecibidas,
      'penaltisCometidos': penaltisCometidos,
      'penaltisRecibidos': penaltisRecibidos,
      'salvadasDeGol': salvadasDeGol,
      'golesEncajadosComoPortero': golesEncajadosComoPortero,
      'paradasComoPortero': paradasComoPortero,
      'penaltisParados': penaltisParados,
      'porteriaImbatida': porteriaImbatida,
    };
  }
}