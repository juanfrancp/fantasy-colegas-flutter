// lib/presentation/league/join_league_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/league.dart';
import '../../domain/services/league_service.dart';

class JoinLeagueScreen extends StatefulWidget {
  const JoinLeagueScreen({super.key});

  @override
  State<JoinLeagueScreen> createState() => _JoinLeagueScreenState();
}

class _JoinLeagueScreenState extends State<JoinLeagueScreen> {
  final LeagueService _leagueService = LeagueService();
  final TextEditingController _nameSearchController = TextEditingController();
  final TextEditingController _codeSearchController = TextEditingController();

  List<League> _leagues = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPublicLeagues();
    _nameSearchController.addListener(_onNameSearchChanged);
  }

  @override
  void dispose() {
    _nameSearchController.removeListener(_onNameSearchChanged);
    _nameSearchController.dispose();
    _codeSearchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPublicLeagues() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final leagues = await _leagueService.getPublicLeagues();
      setState(() {
        _leagues = leagues;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las ligas públicas.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNameSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchLeaguesByName(_nameSearchController.text);
    });
  }

  Future<void> _searchLeaguesByName(String name) async {
    if (name.isEmpty) {
      _loadPublicLeagues();
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final leagues = await _leagueService.searchLeaguesByName(name);
      setState(() {
        _leagues = leagues;
        if (leagues.isEmpty) {
          _errorMessage = 'No se encontraron ligas con ese nombre.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error en la búsqueda.';
        _leagues = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchLeagueByCode() async {
    final code = _codeSearchController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final league = await _leagueService.findLeagueByCode(code);
      setState(() {
        _leagues = [league];
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se encontró ninguna liga con ese código.';
        _leagues = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onLeagueSelected(League league) {
    // Aquí saltará la ventana personalizada que definiremos más adelante
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unirse a ${league.name}'),
        content: Text('¿Estás seguro de que quieres unirte a esta liga?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Lógica para unirse a la liga
              Navigator.of(context).pop();
            },
            child: const Text('Unirme'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unirse a una Liga'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameSearchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeSearchController,
              decoration: InputDecoration(
                labelText: 'Buscar por código de liga',
                prefixIcon: const Icon(Icons.vpn_key),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLeagueByCode,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : ListView.builder(
                          itemCount: _leagues.length,
                          itemBuilder: (context, index) {
                            final league = _leagues[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.shield_outlined, size: 40), // Placeholder para la imagen
                                title: Text(league.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Código: ${league.joinCode ?? "N/A"}'),
                                onTap: () => _onLeagueSelected(league),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}