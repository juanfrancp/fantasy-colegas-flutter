import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';
import 'package:fantasy_colegas_app/core/config/app_colors.dart';

class CreateLeagueScreen extends StatefulWidget {
  const CreateLeagueScreen({super.key});

  @override
  State<CreateLeagueScreen> createState() => _CreateLeagueScreenState();
}

class _CreateLeagueScreenState extends State<CreateLeagueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final LeagueService _leagueService = LeagueService();
  double _currentSliderValue = 5;

  File? _selectedImage;
  bool _isPrivate = false;
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final newLeague = await _leagueService.createLeague(
        name: _nameController.text,
        description: _descriptionController.text,
        teamSize: _currentSliderValue.round(),
        isPrivate: _isPrivate,
      );

      if (_selectedImage != null) {
        try {
          await _leagueService.uploadLeagueImage(
            leagueId: newLeague.id.toString(),
            imageFile: _selectedImage!,
          );
        } catch (e) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text(
                'La liga se creó, pero falló la subida de la imagen.',
              ),
              backgroundColor: AppColors.secondaryAccent.withAlpha(200),
            ),
          );
        }
      }

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('¡Liga creada con éxito!'),
          backgroundColor: AppColors.secondaryAccent,
        ),
      );
      navigator.pop(true);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
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
          'Crear Nueva Liga',
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
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.lightSurface,
                  child: ClipOval(
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/default_league.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
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
                  labelText: 'Nombre de la Liga',
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.lightSurface),
                decoration: InputDecoration(
                  labelText: 'Descripción (Opcional)',
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
              ),
              const SizedBox(height: 16),
              Text(
                'Tamaño del Equipo: ${_currentSliderValue.round()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.lightSurface,
                ),
              ),
              Slider(
                value: _currentSliderValue,
                min: 3,
                max: 11,
                divisions: 8,
                label: _currentSliderValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                  });
                },
                activeColor: AppColors.primaryAccent,
                inactiveColor: AppColors.secondaryAccent.withAlpha(150),
              ),
              SwitchListTile(
                title: const Text(
                  'Liga Privada',
                  style: TextStyle(color: AppColors.lightSurface),
                ),
                value: _isPrivate,
                onChanged: (bool value) {
                  setState(() {
                    _isPrivate = value;
                  });
                },
                activeColor: AppColors.primaryAccent,
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
                    : const Text('Crear Liga'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
