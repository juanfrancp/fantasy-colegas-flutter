import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'package:fantasy_colegas_app/core/config/api_config.dart';
import 'dart:io';

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

  Future<Map<String, dynamic>?> updateUser(String username, String email, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/me');
    try {
        final response = await http.put(
            url,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: json.encode({
                'username': username,
                'email': email,
            }),
        );

        if (response.statusCode == 200) {
            return json.decode(response.body) as Map<String, dynamic>;
        }
        return null;

    } catch (e) {
        log("Excepción en UserRepository.updateUser: $e");
        return null;
    }
  }

  Future<User?> uploadProfileImage(File imageFile, String token) async {
        final url = Uri.parse('${ApiConfig.baseUrl}/users/me/profile-image');
        
        try {
            var request = http.MultipartRequest('POST', url);
            request.headers['Authorization'] = 'Bearer $token';
            request.files.add(
                await http.MultipartFile.fromPath(
                    'image',
                    imageFile.path,
                ),
            );

            var streamedResponse = await request.send();
            var response = await http.Response.fromStream(streamedResponse);

            if (response.statusCode == 200) {
                return User.fromJson(json.decode(response.body));
            } else {
                log('Error al subir imagen (repository): ${response.body}');
                return null;
            }
        } catch (e) {
            log('Excepción en UserRepository.uploadProfileImage: $e');
            return null;
        }
    }
}