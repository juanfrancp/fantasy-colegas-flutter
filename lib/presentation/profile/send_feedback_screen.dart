import 'package:fantasy_colegas_app/core/config/app_colors.dart';
import 'package:fantasy_colegas_app/domain/services/feedback_service.dart';
import 'package:flutter/material.dart';

class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final FeedbackService _feedbackService = FeedbackService();
  
  String _selectedType = 'SUGGESTION'; // Valor por defecto
  bool _isLoading = false;

  final Map<String, String> _typeLabels = {
    'SUGGESTION': 'Sugerencia / Feedback',
    'BUG': 'Reportar Error (Bug)',
    'REPORT': 'Denunciar Abuso',
  };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _feedbackService.sendFeedback(_selectedType, _messageController.text);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias! Tu mensaje ha sido enviado.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Comentarios'),
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.pureWhite,
      ),
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Tu opinión nos ayuda a mejorar la liga.",
                style: TextStyle(color: AppColors.lightSurface, fontSize: 16),
              ),
              const SizedBox(height: 24),
              
              // Selector de Tipo
              DropdownButtonFormField<String>(
                // CAMBIO AQUÍ: Usamos initialValue en lugar de value
                initialValue: _selectedType,
                dropdownColor: AppColors.secondaryAccent,
                style: const TextStyle(color: AppColors.lightSurface),
                decoration: const InputDecoration(
                  labelText: 'Tipo de mensaje',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryAccent)),
                ),
                items: _typeLabels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              
              const SizedBox(height: 16),

              // Caja de Texto
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                style: const TextStyle(color: AppColors.lightSurface),
                decoration: const InputDecoration(
                  labelText: 'Escribe tu comentario aquí...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryAccent)),
                ),
                validator: (val) => val != null && val.length > 10 
                    ? null 
                    : 'Por favor, escribe al menos 10 caracteres.',
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: AppColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: const Text('ENVIAR MENSAJE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}