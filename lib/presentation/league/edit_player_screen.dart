import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fantasy_colegas_app/domain/services/player_service.dart';
import 'package:fantasy_colegas_app/data/models/player.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';

class EditPlayerScreen extends StatefulWidget {
  final int leagueId;
  final Player player;
  
  const EditPlayerScreen({super.key, required this.leagueId, required this.player});

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

    setState(() { _isLoading = true; });
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final updatedPlayer = await _playerService.updatePlayer(
      leagueId: widget.leagueId,
      playerId: widget.player.id,
      name: _nameController.text,
      imageFile: _selectedImage,
    );

    if (mounted) {
      setState(() { _isLoading = false; });
    }

    if (updatedPlayer != null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('¡Jugador actualizado!'), backgroundColor: Colors.green),
      );
      navigator.pop(true); // Devuelve 'true' para refrescar
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Error al actualizar.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para mostrar la imagen actual o la nueva seleccionada
    ImageProvider currentImageProvider;
    if (_selectedImage != null) {
      currentImageProvider = FileImage(_selectedImage!);
    } else if (widget.player.image != null && widget.player.image!.isNotEmpty) {
      currentImageProvider = NetworkImage('${ApiConfig.serverUrl}${widget.player.image}');
    } else {
      currentImageProvider = const AssetImage('assets/images/default_profile.png');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Jugador'),
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
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: currentImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(child: TextButton(onPressed: _pickImage, child: const Text('Cambiar imagen'))),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Jugador', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}