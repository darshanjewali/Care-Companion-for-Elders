import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_client.dart';
import '../services/app_api.dart';
import '../state/app_settings.dart';
import '../state/auth_session.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  bool _sending = false;
  String _status = 'Ready';
  String _healthStatus = 'critical';

  Future<Position?> _getLocation() async {
    // Permissions are required on real devices. For demo, we attempt to read location.
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _sendSos(AppApi api) async {
    setState(() {
      _sending = true;
      _status = 'Sending SOS...';
    });
    try {
      final pos = await _getLocation();
      final lat = pos?.latitude ?? 0;
      final lng = pos?.longitude ?? 0;

      final resp = await api.emergencySos(
        lat: lat,
        lng: lng,
        healthStatus: _healthStatus,
        message: 'Emergency assistance needed',
      );

      setState(() {
        _status = 'SOS sent. Alert ID: ${resp['alertId']}';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to send SOS: $e';
      });
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final auth = context.watch<AuthSession>();
    if (auth.token == null) return const Center(child: Text('Login required'));

    final api = AppApi(client: ApiClient(apiBaseUrl: settings.apiBaseUrl, token: auth.token!));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Emergency SOS', textScaleFactor: settings.textScale, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ToggleButtons(
                isSelected: [_healthStatus == 'critical', _healthStatus == 'fall'],
                onPressed: (i) => setState(() => _healthStatus = i == 0 ? 'critical' : 'fall'),
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.white,
                fillColor: Colors.redAccent,
                color: Colors.redAccent,
                constraints: const BoxConstraints(minWidth: 130, minHeight: 44),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Critical')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Fall')),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                      onPressed: _sending ? null : () => _sendSos(api),
                      child: Text(
                        _sending ? 'Sending...' : 'SOS',
                        textScaleFactor: settings.textScale,
                        style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                textScaleFactor: settings.textScale,
                style: TextStyle(fontWeight: FontWeight.bold, color: _status.startsWith('Failed') ? Colors.red : Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text('One-tap SOS sends your location and alert message to caregivers.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

