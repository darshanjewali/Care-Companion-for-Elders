import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../services/app_api.dart';
import '../state/app_settings.dart';
import '../state/auth_session.dart';

class HealthTrackerScreen extends StatefulWidget {
  const HealthTrackerScreen({super.key});

  @override
  State<HealthTrackerScreen> createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends State<HealthTrackerScreen> {
  final _heartRateCtrl = TextEditingController();
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();

  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _heartRateCtrl.dispose();
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _sugarCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppApi api, {required double scale}) async {
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      final hr = int.parse(_heartRateCtrl.text.trim());
      final sys = int.parse(_sysCtrl.text.trim());
      final dia = int.parse(_diaCtrl.text.trim());
      final sugar = double.parse(_sugarCtrl.text.trim());
      await api.submitHealthRecord(
        heartRate: hr,
        systolicBp: sys,
        diastolicBp: dia,
        bloodSugar: sugar,
      );
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Health record saved')));
    } catch (e) {
      setState(() {
        _error = e.toString();
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final auth = context.watch<AuthSession>();
    if (auth.token == null) return const Center(child: Text('Login required'));

    final api = AppApi(
      client: ApiClient(apiBaseUrl: settings.apiBaseUrl, token: auth.token!),
    );

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: api.getHealthLatest(),
          builder: (context, snapshot) {
            final scale = settings.textScale;
            final latest = snapshot.data as Map<String, dynamic>?;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Health Tracker', textScaleFactor: scale, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Text('Latest', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _vRow('BP', latest?['bp']?.toString() ?? 'N/A'),
                        _vRow('Sugar', latest?['sugar']?.toString() ?? 'N/A'),
                        _vRow('Heart Rate', (latest?['heartRate']?.toString() ?? '0')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Add New Reading', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _sysCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Systolic (e.g. 130)'),
                        ),
                        TextField(
                          controller: _diaCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Diastolic (e.g. 85)'),
                        ),
                        TextField(
                          controller: _sugarCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Sugar (e.g. 140)'),
                        ),
                        TextField(
                          controller: _heartRateCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Heart Rate (e.g. 78)'),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _busy ? null : () => _submit(api, scale: scale),
                            child: Text(_busy ? 'Saving...' : 'Save Reading', textScaleFactor: scale),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _vRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

