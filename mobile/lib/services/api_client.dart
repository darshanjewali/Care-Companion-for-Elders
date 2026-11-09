import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String apiBaseUrl;
  final String token;
  final http.Client _http;

  ApiClient({
    required this.apiBaseUrl,
    required this.token,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path) async {
    final url = Uri.parse('$apiBaseUrl$path');
    final res = await _http.get(url, headers: _authHeaders).timeout(
          const Duration(seconds: 15),
        );
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET $path failed (${res.statusCode}): $body');
    }
    return body;
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$apiBaseUrl$path');
    final res = await _http
        .post(
          url,
          headers: _authHeaders,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    final decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('POST $path failed (${res.statusCode}): $decoded');
    }
    return decoded;
  }
}

