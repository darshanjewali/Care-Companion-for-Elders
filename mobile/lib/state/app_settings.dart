import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  bool _darkMode = false;
  String _language = 'en';
  double _textScale = 1.15; // Elder-friendly default.
  String _apiBaseUrl = 'http://10.0.2.2:8080'; // Android emulator default.

  bool get darkMode => _darkMode;
  String get language => _language;
  double get textScale => _textScale;
  String get apiBaseUrl => _apiBaseUrl;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? false;
    _language = prefs.getString('language') ?? 'en';
    _textScale = prefs.getDouble('textScale') ?? 1.15;
    _apiBaseUrl = prefs.getString('apiBaseUrl') ?? 'http://10.0.2.2:8080';
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = value;
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    _language = value;
    await prefs.setString('language', value);
    notifyListeners();
  }

  Future<void> setTextScale(double value) async {
    final prefs = await SharedPreferences.getInstance();
    _textScale = value;
    await prefs.setDouble('textScale', value);
    notifyListeners();
  }

  Future<void> setApiBaseUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    _apiBaseUrl = value;
    await prefs.setString('apiBaseUrl', value);
    notifyListeners();
  }
}

