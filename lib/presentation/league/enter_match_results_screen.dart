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

  // Controladores para jugadores
  final Map<int, TextEditingController> _goalsControllers = {};
  final Map<int, TextEditingController> _assistsControllers = {};
  final Map<int, TextEditingController> _minutesControllers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar marcador global (si ya tiene resultado, lo mostramos)
    _homeScoreController = TextEditingController(text: widget.match.homeScore?.toString() ?? '0');
    _awayScoreController = TextEditingController(text: widget.match.awayScore?.toString() ?? '0');

    _initializeControllers(widget.match.homeTeam.players);
    _initializeControllers(widget.match.awayTeam.players);
  }

  void _initializeControllers(List<Player> players) {
    for (var player in players) {
      _goalsControllers[player.id] = TextEditingController(text: '0');
      _assistsControllers[player.id] = TextEditingController(text: '0');
      _minutesControllers[player.id] = TextEditingController(text: '90');
    }
  }

  @override
  void dispose() {
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    for (var c in _goalsControllers.values) c.dispose();
    for (var c in _assistsControllers.values) c.dispose();
    for (var c in _minutesControllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _submitResults() async {
    setState(() => _isLoading = true);

    try {
      // 1. Obtener resultado global
      final int homeScore = int.tryParse(_homeScoreController.text) ?? 0;
      final int awayScore = int.tryParse(_awayScoreController.text) ?? 0;

      // 2. Recopilar estadísticas individuales
      List<PlayerMatchStatsUpdate> statsList = [];
      
      void processTeam(List<Player> players) {
        for (var player in players) {
          statsList.add(PlayerMatchStatsUpdate(
            playerId: player.id,
            golesMarcados: int.tryParse(_goalsControllers[player.id]?.text ?? '0') ?? 0,
            asistencias: int.tryParse(_assistsControllers[player.id]?.text ?? '0') ?? 0,
            tiempoJugado: int.tryParse(_minutesControllers[player.id]?.text ?? '0') ?? 0,
          ));
        }
      }

      processTeam(widget.match.homeTeam.players);
      processTeam(widget.match.awayTeam.players);

      // 3. Enviar todo al backend
      await _matchService.submitMatchStats(widget.match.id, homeScore, awayScore, statsList);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resultados actualizados correctamente')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitResults,
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
                  const Divider(color: AppColors.secondaryAccent),
                  const SizedBox(height: 16),
                  _buildTeamSection(widget.match.homeTeam.name, widget.match.homeTeam.players),
                  const SizedBox(height: 24),
                  _buildTeamSection(widget.match.awayTeam.name, widget.match.awayTeam.players),
                  
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitResults,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                    child: const Text('Guardar Todo', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildScoreSection() {
    return Card(
      // CORREGIDO: Usamos un color existente con opacidad en lugar de 'cardSurface'
      color: AppColors.secondaryAccent.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("RESULTADO FINAL", 
              style: TextStyle(color: AppColors.secondaryAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBigScoreInput(widget.match.homeTeam.name, _homeScoreController),
                const Text("-", style: TextStyle(color: AppColors.lightSurface, fontSize: 32, fontWeight: FontWeight.bold)),
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
        Text(label, style: const TextStyle(color: AppColors.lightSurface, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primaryAccent, fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryAccent)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryAccent, width: 2)),
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
        Text(teamName, style: const TextStyle(color: AppColors.primaryAccent, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...players.map((player) => Card(
          // CORREGIDO: Usamos withValues para evitar el warning de deprecated
          color: AppColors.secondaryAccent.withValues(alpha: 0.1), 
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, style: const TextStyle(color: AppColors.lightSurface, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInput('Goles', _goalsControllers[player.id]!),
                    const SizedBox(width: 10),
                    _buildInput('Asist.', _assistsControllers[player.id]!),
                    const SizedBox(width: 10),
                    _buildInput('Min.', _minutesControllers[player.id]!),
                  ],
                )
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: AppColors.lightSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.secondaryAccent, fontSize: 12),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryAccent)),
        ),
      ),
    );
  }
}