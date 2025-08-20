
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';

class UserRepository {
  final String _baseUrl = '${ApiConfig.baseUrl}/users';

  Future<User?> getMe(String token) async {
    final url = Uri.parse('$_baseUrl/me');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }
}