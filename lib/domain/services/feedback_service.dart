import 'package:fantasy_colegas_app/core/api_client.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'package:fantasy_colegas_app/domain/services/auth_service.dart';

class FeedbackService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<void> sendFeedback(String type, String message) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('User not authenticated');

    final client = ApiClient(baseUrl: _baseUrl, token: token);
    
    await client.post(
      'feedback',
      body: {
        'type': type, // Debe coincidir con el ENUM de Java (BUG, SUGGESTION, REPORT)
        'message': message,
      },
    );
  }
}