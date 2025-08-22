
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:flutter/material.dart';
import '../../../data/models/league.dart';
import '../../../domain/services/league_service.dart';

enum JoinAction { sendRequest, cancelRequest, joinPublic }

class LeagueJoinDialog extends StatefulWidget {
  final League league;
  final bool isMember;
  final bool hasPendingRequest;

  const LeagueJoinDialog({
    super.key,
    required this.league,
    required this.isMember,
    required this.hasPendingRequest,
  });

  @override
  State<LeagueJoinDialog> createState() => _LeagueJoinDialogState();
}


class _LeagueJoinDialogState extends State<LeagueJoinDialog> {
  final LeagueService _leagueService = LeagueService();
  bool _isLoading = false;

  void _handleJoinAction(JoinAction action) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String successMessage = '';
      switch (action) {
        case JoinAction.sendRequest:
          await _leagueService.requestToJoinPrivateLeague(widget.league.id);
          successMessage = 'Solicitud enviada correctamente.';
          break;
        case JoinAction.cancelRequest:
          await _leagueService.cancelJoinRequest(widget.league.id);
          successMessage = 'Solicitud cancelada.';
          break;
        case JoinAction.joinPublic:
          if (widget.league.joinCode == null) return;
          await _leagueService.joinPublicLeague(widget.league.joinCode!);
          successMessage = '¡Te has unido a la liga!';
          break;
      }
      _showSnackBar(successMessage);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showSnackBar('Error al procesar la operación.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Widget _buildActionButton() {
    if (widget.isMember) {
      return const SizedBox.shrink();
    }

    if (widget.league.isPrivate) {
      if (widget.hasPendingRequest) {
        return ElevatedButton(
          onPressed: _isLoading ? null : () => _handleJoinAction(JoinAction.cancelRequest),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Cancelar Solicitud'),
        );
      } else {
        return ElevatedButton(
          onPressed: _isLoading ? null : () => _handleJoinAction(JoinAction.sendRequest),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Solicitar Unirse'),
        );
      }
    } else {
      return ElevatedButton(
        onPressed: _isLoading ? null : () => _handleJoinAction(JoinAction.joinPublic),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Unirme a la Liga'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomImage = widget.league.image != null && widget.league.image!.isNotEmpty;
    final String? fullImageUrl = hasCustomImage
        ? '${ApiConfig.serverUrl}${widget.league.image}'
        : null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: hasCustomImage
                      ? Image.network(
                          fullImageUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/default_league.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/default_league.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.league.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.league.isPrivate)
                        const Tooltip(
                          message: 'Liga Privada',
                          child: Icon(Icons.lock, color: Colors.grey),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.league.description ?? 'No hay descripción disponible.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn('Miembros', '${widget.league.participantsCount}'),
                      _buildInfoColumn('Tamaño Equipo', '${widget.league.teamSize}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}