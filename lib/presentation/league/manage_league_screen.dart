import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fantasy_colegas_app/data/models/league.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/presentation/home/home_screen.dart';
import 'widgets/delete_league_dialog.dart';

class ManageLeagueScreen extends StatefulWidget {
  final League league;

  const ManageLeagueScreen({super.key, required this.league});

  @override
  State<ManageLeagueScreen> createState() => _ManageLeagueScreenState();
}

class _ManageLeagueScreenState extends State<ManageLeagueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _leagueService = LeagueService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  late bool _isPrivate;
  late double _teamSize;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.league.name);
    _descriptionController = TextEditingController(text: widget.league.description);
    _isPrivate = widget.league.isPrivate;
    _teamSize = widget.league.teamSize.toDouble();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _onPrivacyChanged(bool newValue) {
    if (_isPrivate && !newValue) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Advertencia de Privacidad'),
          content: const Text('Al hacer la liga pública, todas las solicitudes para unirse serán aceptadas automáticamente. ¿Estás seguro?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                setState(() { _isPrivate = newValue; });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } else {
      setState(() { _isPrivate = newValue; });
    }
  }
  
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text('Confirmar Cambios'),
            content: const Text('¿Estás seguro de que quieres guardar los cambios?'),
            actions: [
                TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop(false)),
                ElevatedButton(child: const Text('Guardar'), onPressed: () => Navigator.of(context).pop(true)),
            ],
        ),
    );

    if (confirmed != true) return;

    setState(() { _isLoading = true; });

    bool teamSizeChanged = widget.league.teamSize != _teamSize.round();
    bool otherDataChanged = widget.league.name != _nameController.text ||
                            widget.league.description != _descriptionController.text ||
                            widget.league.isPrivate != _isPrivate ||
                            _selectedImage != null;

    bool success = true;
    String? finalImageUrl = widget.league.image;

    try {
      // 1. Si la imagen ha cambiado, la subimos primero.
      if (_selectedImage != null) {
        final newImageUrl = await _leagueService.uploadLeagueImage(
            leagueId: widget.league.id.toString(),
            imageFile: _selectedImage!,
        );
        if (newImageUrl != null) {
          finalImageUrl = newImageUrl;
        }
      }

      // 2. Si el tamaño del equipo ha cambiado, llamamos al endpoint específico.
      if (teamSizeChanged) {
        final updatedLeague = await _leagueService.updateLeagueTeamSize(
          leagueId: widget.league.id,
          newTeamSize: _teamSize.round(),
        );
        if (updatedLeague == null) success = false;
      }

      // 3. Si otros datos han cambiado (y la operación anterior no ha fallado), actualizamos el resto.
      if (otherDataChanged && success) {
        final updatedLeague = await _leagueService.updateLeague(
          widget.league.id,
          _nameController.text,
          _descriptionController.text,
          _isPrivate,
          _teamSize.round(), // Se envía el tamaño de equipo por si acaso, aunque la lógica principal ya se ejecutó.
          finalImageUrl,
        );
        if (updatedLeague == null) success = false;
      }

    } catch (e) {
      success = false;
    }

    setState(() { _isLoading = false; });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Liga actualizada con éxito!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar la liga.'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _showDeleteConfirmation() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DeleteLeagueConfirmationDialog(),
    );

    if (confirmed != true || !mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() { _isLoading = true; });
    final success = await _leagueService.deleteLeague(widget.league.id);
    
    if (!mounted) return;
    
    setState(() { _isLoading = false; });

    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Liga eliminada con éxito.'), backgroundColor: Colors.green),
      );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Error al eliminar la liga.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Liga'),
        actions: [
          IconButton(
            icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveChanges,
            tooltip: 'Guardar Cambios',
          )
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      child: ClipOval(
                        child: _selectedImage != null
                          ? Image.file(_selectedImage!, width: 120, height: 120, fit: BoxFit.cover)
                          : Image.network(
                              '${ApiConfig.serverUrl}${widget.league.image}',
                              width: 120, height: 120, fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Image.asset('assets/images/default_league.png', fit: BoxFit.cover),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _pickImage, child: const Text('Cambiar imagen')),
                  const SizedBox(height: 24),
                  
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre de la Liga', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'El nombre es obligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  Text('Tamaño del Equipo: ${_teamSize.round()}'),
                  Slider(
                    value: _teamSize,
                    min: 3, max: 11, divisions: 8,
                    label: _teamSize.round().toString(),
                    onChanged: (v) => setState(() => _teamSize = v),
                  ),
                  
                  SwitchListTile(
                    title: const Text('Liga Privada'),
                    value: _isPrivate,
                    onChanged: _onPrivacyChanged,
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(color: Colors.red),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _showDeleteConfirmation,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Eliminar Liga'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }
}
