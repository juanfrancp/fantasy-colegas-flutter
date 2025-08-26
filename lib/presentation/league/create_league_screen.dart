import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fantasy_colegas_app/domain/services/league_service.dart';

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
    if (_formKey.currentState!.validate()) {
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

        if (newLeague != null) {
          if (_selectedImage != null) {
            final success = await _leagueService.uploadLeagueImage(
              leagueId: newLeague.id.toString(),
              imageFile: _selectedImage!,
            );

            if (success == null) {
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                    content: Text(
                        'La liga se creó, pero falló la subida de la imagen.'),
                    backgroundColor: Colors.orange),
              );
            }
          }

          scaffoldMessenger.showSnackBar(
            const SnackBar(
                content: Text('¡Liga creada con éxito!'),
                backgroundColor: Colors.green),
          );
          
          navigator.pop(true); 

        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
                content: Text('Error al crear la liga.'),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
              content: Text('Ocurrió un error: $e'),
              backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Liga'),
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
                  backgroundColor: Colors.grey.shade300,
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
              Center(child: TextButton(onPressed: _pickImage, child: const Text('Elegir imagen'))),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre de la Liga', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción (Opcional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Text(
                'Tamaño del Equipo: ${_currentSliderValue.round()}',
                style: Theme.of(context).textTheme.titleMedium,
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
              ),
              SwitchListTile(
                title: const Text('Liga Privada'),
                value: _isPrivate,
                onChanged: (bool value) {
                  setState(() {
                    _isPrivate = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Crear Liga'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}