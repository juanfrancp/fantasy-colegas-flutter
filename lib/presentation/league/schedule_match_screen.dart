import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/data/models/match_create.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/domain/services/match_service.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';
import 'package:fantasy_colegas_app/presentation/league/widgets/player_selection_dialog.dart';

class ScheduleMatchScreen extends StatefulWidget {
  final League league;

  const ScheduleMatchScreen({super.key, required this.league});

  @override
  State<ScheduleMatchScreen> createState() => _ScheduleMatchScreenState();
}

class _ScheduleMatchScreenState extends State<ScheduleMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homeTeamController = TextEditingController();
  final _awayTeamController = TextEditingController();

  final LeagueService _leagueService = LeagueService();
  final MatchService _matchService = MatchService();

  bool _isLoading = true;
  List<Player> _allLeaguePlayers = [];
  DateTime? _selectedDate;
  List<Player> _homeTeamPlayers = [];
  List<Player> _awayTeamPlayers = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaguePlayers();
  }

  Future<void> _fetchLeaguePlayers() async {
    try {
      final players = await _leagueService.getLeaguePlayers(widget.league.id);
      if (!mounted) return;
      setState(() {
        _allLeaguePlayers = players;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar jugadores: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una fecha para el partido')),
      );
      return;
    }
    if (_homeTeamPlayers.isEmpty || _awayTeamPlayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambos equipos deben tener al menos un jugador')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final matchToCreate = MatchCreate(
      leagueId: widget.league.id.toString(),
      homeTeamName: _homeTeamController.text,
      awayTeamName: _awayTeamController.text,
      matchDate: _selectedDate!,
      homeTeamPlayerIds: _homeTeamPlayers.map((p) => p.id).toList(),
      awayTeamPlayerIds: _awayTeamPlayers.map((p) => p.id).toList(),
    );

    try {
      await _matchService.createMatch(matchToCreate);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Partido programado con éxito!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear el partido: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programar Nuevo Partido'),
        backgroundColor: AppColors.primaryAccent,
      ),
      backgroundColor: AppColors.darkBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(_homeTeamController, 'Nombre del Equipo Local'),
                    const SizedBox(height: 16),
                    _buildTextField(_awayTeamController, 'Nombre del Equipo Visitante'),
                    const SizedBox(height: 24),
                    _buildDatePicker(),
                    const SizedBox(height: 24),
                    _buildPlayerSelector(true),
                    const SizedBox(height: 8),
                    _buildPlayerList(_homeTeamPlayers),
                    const SizedBox(height: 24),
                    _buildPlayerSelector(false),
                    const SizedBox(height: 8),
                    _buildPlayerList(_awayTeamPlayers),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Programar Partido'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  TextFormField _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.lightSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.secondaryAccent),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryAccent)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryAccent)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: AppColors.secondaryAccent),
        const SizedBox(width: 16),
        Text(
          _selectedDate == null ? 'Seleccionar fecha del partido' : 'Fecha: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(color: AppColors.lightSurface, fontSize: 16),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _selectDate(context),
          icon: const Icon(Icons.edit, color: AppColors.primaryAccent),
        ),
      ],
    );
  }

  Widget _buildPlayerSelector(bool isHomeTeam) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isHomeTeam ? 'Jugadores Locales' : 'Jugadores Visitantes',
          style: const TextStyle(color: AppColors.lightSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: () => _selectPlayers(isHomeTeam),
          icon: const Icon(Icons.add, color: AppColors.primaryAccent),
          label: const Text('Seleccionar', style: TextStyle(color: AppColors.primaryAccent)),
        ),
      ],
    );
  }

  Widget _buildPlayerList(List<Player> players) {
    if (players.isEmpty) {
      return const Text(
        'Aún no se han seleccionado jugadores.',
        style: TextStyle(color: AppColors.secondaryAccent),
      );
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: players.map((player) => Chip(
        label: Text(player.name),
        backgroundColor: AppColors.secondaryAccent.withAlpha(50),
      )).toList(),
    );
  }

  Future<void> _selectPlayers(bool isHomeTeam) async {
    final List<Player>? selected = await showDialog<List<Player>>(
      context: context,
      builder: (context) => PlayerSelectionDialog(
        allPlayers: _allLeaguePlayers,
        initiallySelectedPlayers: isHomeTeam ? _homeTeamPlayers : _awayTeamPlayers,
      ),
    );

    if (selected != null) {
      setState(() {
        if (isHomeTeam) {
          _homeTeamPlayers = selected;
        } else {
          _awayTeamPlayers = selected;
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

}