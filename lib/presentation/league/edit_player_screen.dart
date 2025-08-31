import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fantasy_colegas_app/domain/services/player_service.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class EditPlayerScreen extends StatefulWidget {
  final int leagueId;
  final Player player;

  const EditPlayerScreen({
    super.key,
    required this.leagueId,
    required this.player,
  });

  @override
  State<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final PlayerService _playerService = PlayerService();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      await _playerService.updatePlayer(
        leagueId: widget.leagueId,
        playerId: widget.player.id,
        name: _nameController.text,
        imageFile: _selectedImage,
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text('¡Jugador actualizado!'),
          backgroundColor: AppColors.secondaryAccent,
        ),
      );
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString().replaceFirst("Exception: ", "")}',
          ),
          backgroundColor: AppColors.primaryAccent,
        ),
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
    ImageProvider currentImageProvider;
    if (_selectedImage != null) {
      currentImageProvider = FileImage(_selectedImage!);
    } else if (widget.player.image != null && widget.player.image!.isNotEmpty) {
      currentImageProvider = NetworkImage(
        '${ApiConfig.serverUrl}${widget.player.image}',
      );
    } else {
      currentImageProvider = const AssetImage(
        'assets/images/default_player.png',
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Editar Jugador',
          style: TextStyle(color: AppColors.lightSurface),
        ),
        backgroundColor: AppColors.darkBackground,
        iconTheme: const IconThemeData(color: AppColors.lightSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.lightSurface,
                    backgroundImage: currentImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: const Text(
                    'Cambiar imagen',
                    style: TextStyle(color: AppColors.secondaryAccent),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.lightSurface),
                decoration: InputDecoration(
                  labelText: 'Nombre del Jugador',
                  labelStyle: const TextStyle(color: AppColors.secondaryAccent),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.secondaryAccent.withAlpha(100),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.lightSurface),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: AppColors.pureWhite,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.pureWhite,
                      )
                    : const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
