import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_api.dart';

class AuthSession extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? _name;
  String? _role; // elder/caregiver/doctor

  bool _loading = false;
  String? get token => _token;
  String? get name => _name;
  String? get role => _role;
  bool get loading => _loading;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> load() async {
    _token = await _storage.read(key: 'token');
    _name = await _storage.read(key: 'name');
    _role = await _storage.read(key: 'role');
    notifyListeners();
  }

  Future<void> loginOtp({
    required String phone,
    required String otp,
    String? role,
    required String apiBaseUrl,
  }) async {
    _loading = true;
    notifyListeners();
    final resp = await AuthApi(apiBaseUrl: apiBaseUrl).loginWithOtp(phone: phone, otp: otp, role: role);
    _token = resp['token'] as String?;
    _name = (resp['user'] as Map)['name'] as String?;
    _role = (resp['user'] as Map)['role'] as String?;

    await _storage.write(key: 'token', value: _token);
    await _storage.write(key: 'name', value: _name);
    await _storage.write(key: 'role', value: _role);

    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _name = null;
    _role = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}

