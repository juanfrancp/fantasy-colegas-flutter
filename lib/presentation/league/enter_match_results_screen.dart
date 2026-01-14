import 'package:fantasy_colegas_app/core/config/app_colors.dart';
import 'package:fantasy_colegas_app/data/models/match.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/data/models/player_match_stats_update.dart';
import 'package:fantasy_colegas_app/domain/services/match_service.dart';
import 'package:flutter/material.dart';

class EnterMatchResultsScreen extends StatefulWidget {
  final Match match;

  const EnterMatchResultsScreen({super.key, required this.match});

  @override
  State<EnterMatchResultsScreen> createState() => _EnterMatchResultsScreenState();
}

class _EnterMatchResultsScreenState extends State<EnterMatchResultsScreen> {
  final MatchService _matchService = MatchService();
  bool _isLoading = false;

  // Controladores para el Marcador Global
  late TextEditingController _homeScoreController;
  late TextEditingController _awayScoreController;

  // Mapas de Controladores por Jugador (Key: Player ID)
  // Estadísticas Ofensivas/Generales
  final Map<int, TextEditingController> _goalsControllers = {};
  final Map<int, TextEditingController> _assistsControllers = {};
  final Map<int, TextEditingController> _yellowCardControllers = {};
  final Map<int, TextEditingController> _redCardControllers = {};

  // Estadísticas Defensivas/Portero
  final Map<int, TextEditingController> _savesControllers = {}; // Paradas
  final Map<int, TextEditingController> _concededControllers = {}; // Goles encajados
  final Map<int, bool> _cleanSheetValues = {}; // Portería a 0 (Clean Sheet)

  @override
  void initState() {
    super.initState();
    // Inicializar marcador global (Si ya existe, se muestra para editar)
    _homeScoreController = TextEditingController(text: widget.match.homeScore?.toString() ?? '0');
    _awayScoreController = TextEditingController(text: widget.match.awayScore?.toString() ?? '0');

    // Inicializar controladores de jugadores con los datos existentes
    _initializeControllers(widget.match.homeTeam.players);
    _initializeControllers(widget.match.awayTeam.players);
  }

  // --- MODIFICACIÓN CLAVE AQUÍ ---
  // Ahora inicializamos los controladores con los datos que vienen del Player (si existen)
  void _initializeControllers(List<Player> players) {
    for (var player in players) {
      // Ofensivas
      _goalsControllers[player.id] = TextEditingController(
          text: player.golesMarcados?.toString() ?? '0');
      
      _assistsControllers[player.id] = TextEditingController(
          text: player.asistencias?.toString() ?? '0');

      // Disciplinarias
      _yellowCardControllers[player.id] = TextEditingController(
          text: player.tarjetasAmarillas?.toString() ?? '0');
      
      _redCardControllers[player.id] = TextEditingController(
          text: player.tarjetasRojas?.toString() ?? '0');

      // Portero
      _savesControllers[player.id] = TextEditingController(
          text: player.paradasComoPortero?.toString() ?? '0');
      
      _concededControllers[player.id] = TextEditingController(
          text: player.golesEncajadosComoPortero?.toString() ?? '0');

      // Booleanos
      _cleanSheetValues[player.id] = player.porteriaImbatida ?? false;
    }
  }

  @override
  void dispose() {
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    // Limpieza masiva de controladores
    for (var c in _goalsControllers.values) c.dispose();
    for (var c in _assistsControllers.values) c.dispose();
    for (var c in _yellowCardControllers.values) c.dispose();
    for (var c in _redCardControllers.values) c.dispose();
    for (var c in _savesControllers.values) c.dispose();
    for (var c in _concededControllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _submitResults() async {
    setState(() => _isLoading = true);

    try {
      // 1. Obtener resultado global del partido
      final int homeScore = int.tryParse(_homeScoreController.text) ?? 0;
      final int awayScore = int.tryParse(_awayScoreController.text) ?? 0;

      // 2. Recopilar estadísticas individuales
      List<PlayerMatchStatsUpdate> statsList = [];

      void processTeam(List<Player> players) {
        for (var player in players) {
          statsList.add(PlayerMatchStatsUpdate(
            playerId: player.id,
            // Ofensivas
            golesMarcados: int.tryParse(_goalsControllers[player.id]?.text ?? '0') ?? 0,
            asistencias: int.tryParse(_assistsControllers[player.id]?.text ?? '0') ?? 0,
            // Disciplinarias
            tarjetasAmarillas: int.tryParse(_yellowCardControllers[player.id]?.text ?? '0') ?? 0,
            tarjetasRojas: int.tryParse(_redCardControllers[player.id]?.text ?? '0') ?? 0,
            // Portero / Defensa
            paradasComoPortero: int.tryParse(_savesControllers[player.id]?.text ?? '0') ?? 0,
            golesEncajadosComoPortero: int.tryParse(_concededControllers[player.id]?.text ?? '0') ?? 0,
            porteriaImbatida: _cleanSheetValues[player.id] ?? false,
            // Otros campos por defecto a 0
            fallosClarosDeGol: 0,
            salvadasDeGol: 0,
            faltasCometidas: 0,
            faltasRecibidas: 0,
            penaltisCometidos: 0,
            penaltisRecibidos: 0,
            penaltisParados: 0,
          ));
        }
      }

      processTeam(widget.match.homeTeam.players);
      processTeam(widget.match.awayTeam.players);

      // 3. Enviar al backend
      await _matchService.submitMatchStats(widget.match.id, homeScore, awayScore, statsList);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resultados y Puntos actualizados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Volver y recargar
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Introducir Resultados'),
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.pureWhite, // Aseguramos que el texto sea blanco
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitResults,
            tooltip: 'Guardar Resultados',
          )
        ],
      ),
      backgroundColor: AppColors.darkBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- SECCIÓN MARCADOR GLOBAL ---
                  _buildScoreSection(),
                  const SizedBox(height: 24),

                  // --- SECCIÓN JUGADORES ---
                  const Text("ESTADÍSTICAS INDIVIDUALES",
                      style: TextStyle(
                          color: AppColors.secondaryAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  const Divider(color: AppColors.secondaryAccent),
                  const SizedBox(height: 16),

                  _buildTeamSection(widget.match.homeTeam.name, widget.match.homeTeam.players),
                  const SizedBox(height: 24),
                  _buildTeamSection(widget.match.awayTeam.name, widget.match.awayTeam.players),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitResults,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          foregroundColor: AppColors.pureWhite, // Texto blanco
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text('CALCULAR PUNTOS Y GUARDAR',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildScoreSection() {
    return Card(
      color: AppColors.secondaryAccent.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("MARCADOR FINAL",
                style: TextStyle(
                    color: AppColors.secondaryAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBigScoreInput(widget.match.homeTeam.name, _homeScoreController),
                const Text("-",
                    style: TextStyle(
                        color: AppColors.lightSurface,
                        fontSize: 40,
                        fontWeight: FontWeight.bold)),
                _buildBigScoreInput(widget.match.awayTeam.name, _awayScoreController),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigScoreInput(String label, TextEditingController controller) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.lightSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.primaryAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondaryAccent)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.primaryAccent, width: 2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection(String teamName, List<Player> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(teamName,
              style: const TextStyle(
                  color: AppColors.primaryAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        ...players.map((player) => Card(
              color: AppColors.secondaryAccent.withValues(alpha: 0.1),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.name,
                        style: const TextStyle(
                            color: AppColors.lightSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 12),

                    // FILA 1: Ataque y Disciplina
                    Row(
                      children: [
                        _buildInput('Goles', _goalsControllers[player.id]!,
                            color: Colors.greenAccent),
                        const SizedBox(width: 8),
                        _buildInput('Asist.', _assistsControllers[player.id]!,
                            color: Colors.lightBlueAccent),
                        const SizedBox(width: 8),
                        _buildInput('Amaril.', _yellowCardControllers[player.id]!,
                            color: Colors.yellowAccent),
                        const SizedBox(width: 8),
                        _buildInput('Rojas', _redCardControllers[player.id]!,
                            color: Colors.redAccent),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // FILA 2: Portero y Defensa
                    Row(
                      children: [
                        _buildInput('Paradas', _savesControllers[player.id]!,
                            color: Colors.orangeAccent),
                        const SizedBox(width: 8),
                        _buildInput('Encajad.', _concededControllers[player.id]!,
                            color: Colors.deepOrangeAccent),
                        const SizedBox(width: 12),

                        // Switch Portería Imbatida
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.secondaryAccent
                                        .withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0),
                            child: Column(
                              children: [
                                const Text("Imbatido",
                                    style: TextStyle(
                                        color: AppColors.secondaryAccent,
                                        fontSize: 10)),
                                Switch(
                                  value: _cleanSheetValues[player.id]!,
                                  activeColor: AppColors.primaryAccent,
                                  inactiveThumbColor: Colors.grey,
                                  inactiveTrackColor:
                                      Colors.grey.withValues(alpha: 0.3),
                                  onChanged: (val) {
                                    setState(() {
                                      _cleanSheetValues[player.id] = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      {Color? color}) {
    return Expanded(
      flex: 2,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: color ?? AppColors.lightSurface, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: AppColors.secondaryAccent.withValues(alpha: 0.8),
              fontSize: 11),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.secondaryAccent.withValues(alpha: 0.3))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color ?? AppColors.primaryAccent)),
        ),
      ),
    );
  }
}