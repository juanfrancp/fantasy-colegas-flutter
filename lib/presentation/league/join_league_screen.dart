import 'dart:async';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/presentation/league/widgets/league_join_dialog.dart';
import 'package:flutter/material.dart';

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
  List<int> _myLeagueIds = [];
  List<int> _pendingRequestLeagueIds = [];
  bool _actionTaken = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final responses = await Future.wait([
        _leagueService.getPublicLeagues(),
        _leagueService.getMyLeagues(),
        _leagueService.getMyPendingRequestLeagueIds(),
      ]);

      if (mounted) {
        setState(() {
          _leagues = responses[0] as List<League>;
          final myLeagues = responses[1] as List<League>;
          _myLeagueIds = myLeagues.map((league) => league.id).toList();
          _pendingRequestLeagueIds = responses[2] as List<int>;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar los datos.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      _loadInitialData();
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final leagues = await _leagueService.searchLeaguesByName(name);
      if (mounted) {
        setState(() {
          _leagues = leagues;
          if (leagues.isEmpty) {
            _errorMessage = 'No se encontraron ligas con ese nombre.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error en la búsqueda.';
          _leagues = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      if (mounted) {
        setState(() {
          _leagues = [league];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No se encontró ninguna liga con ese código.';
          _leagues = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onLeagueSelected(League league) {
    final bool isMember = _myLeagueIds.contains(league.id);
    final bool hasPendingRequest = _pendingRequestLeagueIds.contains(league.id);

    showDialog(
      context: context,
      builder: (context) => LeagueJoinDialog(
        league: league,
        isMember: isMember,
        hasPendingRequest: hasPendingRequest,
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          _actionTaken = true;
        });
        _loadInitialData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_actionTaken);
      },
      child: Scaffold(
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
                              final hasCustomImage = league.image != null && league.image!.isNotEmpty;
                              final fullImageUrl = hasCustomImage ? '${ApiConfig.serverUrl}${league.image}' : null;

                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey.shade200,
                                    child: ClipOval(
                                      child: hasCustomImage
                                        ? Image.network(
                                            fullImageUrl!,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/default_league.png',
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'assets/images/default_league.png',
                                            fit: BoxFit.cover,
                                          ),
                                    ),
                                  ),
                                  title: Text(league.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(league.description ?? 'Sin descripción'),
                                  onTap: () => _onLeagueSelected(league),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
