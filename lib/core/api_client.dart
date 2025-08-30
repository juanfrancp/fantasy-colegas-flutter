import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'Error $statusCode: $message';
}

class ApiClient {
  final String baseUrl;
  final String token;

  ApiClient({required this.baseUrl, required this.token});

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(url, headers: _authHeaders);
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(url, headers: _authHeaders, body: json.encode(body));
    return _handleResponse(response);
  }
  
  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.patch(url, headers: _authHeaders, body: json.encode(body));
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.put(url, headers: _authHeaders, body: json.encode(body));
    return _handleResponse(response);
  }
  
  Future<void> delete(String endpoint) async {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http.delete(url, headers: _authHeaders);
      if (response.statusCode < 200 || response.statusCode >= 300) {
          _handleResponse(response);
      }
  }

  Future<dynamic> multipartPost(String endpoint, File file, String fieldName) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(_authHeaders)
      ..files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseBody.isEmpty) return null;
        return json.decode(responseBody);
    } else {
        final errorBody = json.decode(responseBody);
        throw ApiException(errorBody['message'] ?? 'Error en la subida', response.statusCode);
    }
  }

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null; // Para respuestas 204 No Content
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      final errorBody = json.decode(response.body);
      throw ApiException(errorBody['message'] ?? 'Error desconocido', response.statusCode);
    }
  }
}