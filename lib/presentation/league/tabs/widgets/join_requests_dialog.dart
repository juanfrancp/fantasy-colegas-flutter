import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/join_request.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';

class JoinRequestsDialog extends StatefulWidget {
  final int leagueId;

  const JoinRequestsDialog({super.key, required this.leagueId});

  @override
  State<JoinRequestsDialog> createState() => _JoinRequestsDialogState();
}

class _JoinRequestsDialogState extends State<JoinRequestsDialog> {
  final LeagueService _leagueService = LeagueService();
  late Future<List<JoinRequest>> _requestsFuture;
  bool _dataChanged = false;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _leagueService.getPendingJoinRequests(widget.leagueId);
  }

  void _handleRequest(JoinRequest request, bool accept) async {
    try {
      if (accept) {
        await _leagueService.acceptJoinRequest(widget.leagueId, request.id);
      } else {
        await _leagueService.rejectJoinRequest(widget.leagueId, request.id);
      }
      
      setState(() {
        _dataChanged = true;
        _requestsFuture = _leagueService.getPendingJoinRequests(widget.leagueId);
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar la solicitud: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Solicitudes Pendientes'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<JoinRequest>>(
          future: _requestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error al cargar las solicitudes.'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay solicitudes pendientes.'));
            }

            final requests = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final user = request.user;
                final hasImage = user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty;
                final fullImageUrl = hasImage ? '${ApiConfig.serverUrl}${user.profileImageUrl}' : null;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    // --- CORRECCIÓN DE LA IMAGEN AQUÍ ---
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: ClipOval(
                        child: hasImage
                          ? Image.network(
                              fullImageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/default_profile.png',
                                  width: 40, height: 40, fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/default_profile.png',
                              width: 40, height: 40, fit: BoxFit.cover,
                            ),
                      ),
                    ),
                    title: Flexible(
                      child: Text(
                        user.username,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _handleRequest(request, true),
                          tooltip: 'Aceptar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _handleRequest(request, false),
                          tooltip: 'Rechazar',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_dataChanged),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}