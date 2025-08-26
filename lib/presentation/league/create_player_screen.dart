import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fantasy_colegas_app/domain/services/player_service.dart';

class CreatePlayerScreen extends StatefulWidget {
  final int leagueId;
  const CreatePlayerScreen({super.key, required this.leagueId});

  @override
  State<CreatePlayerScreen> createState() => _CreatePlayerScreenState();
}

class _CreatePlayerScreenState extends State<CreatePlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final PlayerService _playerService = PlayerService();

  File? _selectedImage;
  bool _isLoading = false;

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

    final newPlayer = await _playerService.createPlayer(
      leagueId: widget.leagueId,
      name: _nameController.text,
      imageFile: _selectedImage,
    );

    if (mounted) {
      setState(() { _isLoading = false; });
    }

    if (newPlayer != null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('¡Jugador creado con éxito!'), backgroundColor: Colors.green),
      );
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Error al crear el jugador.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nuevo Jugador'),
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
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(child: TextButton(onPressed: _pickImage, child: const Text('Elegir imagen'))),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Jugador', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Añadir Jugador'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}