import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  final String apiBaseUrl;
  const AuthApi({required this.apiBaseUrl});

  Future<Map<String, dynamic>> loginWithOtp({
    required String phone,
    required String otp,
    String? role,
  }) async {
    final url = Uri.parse('$apiBaseUrl/api/auth/login');
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone': phone,
            'otp': otp,
            if (role != null && role.isNotEmpty) 'role': role,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Login failed: ${res.body}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return decoded;
  }

  Future<String> requestOtp({required String phone}) async {
    final url = Uri.parse('$apiBaseUrl/api/auth/request-otp');
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('OTP request failed: ${res.body}');
    }
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return decoded['otp'] as String;
  }
}

