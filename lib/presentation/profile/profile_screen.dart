// Archivo: lib/presentation/profile/profile_screen.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fantasy_colegas_app/data/models/user.dart';
import 'package:fantasy_colegas_app/domain/services/user_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  late Future<User> _userFuture;
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
  }

  Future<User> _loadUserData() async {
    try {
      final user = await _userService.getMe();
      if (mounted) {
        setState(() {
          _usernameController.text = user.username;
          _emailController.text = user.email ?? '';
        });
      }
      return user;
    } catch (e) {
      log("Error cargando datos del usuario: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el perfil: ${e.toString().replaceFirst("Exception: ", "")}')),
        );
      }
      throw Exception('Failed to load user data');
    }
  }

  Future<void> _saveChanges() async {
    final messenger = ScaffoldMessenger.of(context);

    final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar cambios'),
            content: const Text('¿Estás seguro de que quieres guardar los cambios en tu perfil?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Confirmar'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        });

    if (!mounted || confirm != true) return;

    setState(() { _isLoading = true; });

    try {
      await _userService.updateProfile(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
      );
      
      messenger.showSnackBar(
        const SnackBar(content: Text('¡Perfil actualizado con éxito!'), backgroundColor: Colors.green),
      );
      
      setState(() {
        _userFuture = _loadUserData();
      });

    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _selectedImage = File(image.path);
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() { _isLoading = true; });

    try {
      await _userService.uploadProfileImage(_selectedImage!);
      
      messenger.showSnackBar(
        const SnackBar(content: Text('Imagen de perfil actualizada.'), backgroundColor: Colors.green),
      );
      setState(() {
        _userFuture = _loadUserData();
        _selectedImage = null;
      });
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Perfil'),
      ),
      body: FutureBuilder<User>( // <-- Cambiado a User (no nullable)
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No se pudieron cargar los datos del perfil.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          final user = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.25,
                  backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                      ? NetworkImage('${ApiConfig.serverUrl}${user.profileImageUrl}')
                      : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Modificar imagen de perfil'),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar Cambios'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}