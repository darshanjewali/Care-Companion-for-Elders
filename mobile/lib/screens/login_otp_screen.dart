import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_settings.dart';
import '../state/auth_session.dart';
import '../services/auth_api.dart';
import 'main_tabs_screen.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  String? _error;
  String? _debugOtp;
  bool _busy = false;
  String _role = 'ELDER';

  Future<void> _requestOtp() async {
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      final settings = context.read<AppSettings>();
      final api = AuthApi(apiBaseUrl: settings.apiBaseUrl);
      final otp = await api.requestOtp(phone: _phoneCtrl.text.trim());
      setState(() => _debugOtp = otp);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP requested. Debug OTP: $otp')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _login() async {
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      final settings = context.read<AppSettings>();
      final auth = context.read<AuthSession>();
      await auth.loginOtp(
        phone: _phoneCtrl.text.trim(),
        otp: _otpCtrl.text.trim(),
        role: _role,
        apiBaseUrl: settings.apiBaseUrl,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainTabsScreen()),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Enter Phone Number', style: TextStyle(fontSize: 22 * settings.textScale, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone',
                  ),
                ),
                const SizedBox(height: 16),
                Text('Enter OTP', style: TextStyle(fontSize: 22 * settings.textScale, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'OTP',
                  ),
                ),
                const SizedBox(height: 12),
                if (_debugOtp != null)
                  Text('Debug OTP: $_debugOtp', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Select role', style: TextStyle(fontSize: 18 * settings.textScale, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  value: _role,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'ELDER', child: Text('Elder')),
                    DropdownMenuItem(value: 'CAREGIVER', child: Text('Caregiver')),
                    DropdownMenuItem(value: 'DOCTOR', child: Text('Doctor')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _role = v);
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _requestOtp,
                    child: const Text('Request OTP'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: _busy ? null : _login,
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tip: In development, OTP is usually 1234.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16 * settings.textScale),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}



