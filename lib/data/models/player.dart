class Player {
  final int id;
  final String name;
  final String? image;
  final int totalPoints;
  
  final double? totalFieldPoints;
  final double? totalGoalkeeperPoints;

  final int? golesMarcados;
  final int? asistencias;
  final int? fallosClarosDeGol;
  final int? faltasCometidas;
  final int? faltasRecibidas;
  final int? penaltisCometidos;
  final int? penaltisRecibidos;
  final int? tarjetasAmarillas;
  final int? tarjetasRojas;
  final int? salvadasDeGol;

  final int? paradasComoPortero;
  final int? golesEncajadosComoPortero;
  final int? penaltisParados;
  final bool? porteriaImbatida;

  Player({
    required this.id,
    required this.name,
    this.image,
    required this.totalPoints,
    this.totalFieldPoints,
    this.totalGoalkeeperPoints,
    this.golesMarcados,
    this.asistencias,
    this.fallosClarosDeGol,
    this.faltasCometidas,
    this.faltasRecibidas,
    this.penaltisCometidos,
    this.penaltisRecibidos,
    this.tarjetasAmarillas,
    this.tarjetasRojas,
    this.salvadasDeGol,
    this.paradasComoPortero,
    this.golesEncajadosComoPortero,
    this.penaltisParados,
    this.porteriaImbatida,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      totalPoints: json['totalPoints'] ?? 0,
      
      totalFieldPoints: (json['totalFieldPoints'] as num?)?.toDouble(),
      totalGoalkeeperPoints: (json['totalGoalkeeperPoints'] as num?)?.toDouble(),

      golesMarcados: json['golesMarcados'],
      asistencias: json['asistencias'],
      fallosClarosDeGol: json['fallosClarosDeGol'],
      faltasCometidas: json['faltasCometidas'],
      faltasRecibidas: json['faltasRecibidas'],
      penaltisCometidos: json['penaltisCometidos'],
      penaltisRecibidos: json['penaltisRecibidos'],
      tarjetasAmarillas: json['tarjetasAmarillas'],
      tarjetasRojas: json['tarjetasRojas'],
      salvadasDeGol: json['salvadasDeGol'],
      
      paradasComoPortero: json['paradasComoPortero'],
      golesEncajadosComoPortero: json['golesEncajadosComoPortero'],
      penaltisParados: json['penaltisParados'],
      porteriaImbatida: json['porteriaImbatida'],
    );
  }
}