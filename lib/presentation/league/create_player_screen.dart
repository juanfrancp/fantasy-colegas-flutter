import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fantasy_colegas_app/domain/services/player_service.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

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

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      await _playerService.createPlayer(
        leagueId: widget.leagueId,
        name: _nameController.text,
        imageFile: _selectedImage,
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text('¡Jugador creado con éxito!'),
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
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Añadir Nuevo Jugador',
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
                            color: AppColors.darkBackground,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: const Text(
                    'Elegir imagen',
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
                    : const Text('Añadir Jugador'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
