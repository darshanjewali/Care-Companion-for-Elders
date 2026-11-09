import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_client.dart';
import '../services/app_api.dart';
import '../state/app_settings.dart';
import '../state/auth_session.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _doctorCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  bool _busy = false;
  String? _error;

  Future<List<dynamic>> _load(AppApi api) => api.getMyAppointments();

  Future<void> _add(AppApi api) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final doctorId = int.parse(_doctorCtrl.text.trim());
      final time = _timeCtrl.text.trim();
      final reason = _reasonCtrl.text.trim();
      await api.createAppointment(
        doctorId: doctorId,
        appointmentTime: time,
        reason: reason.isEmpty ? 'General checkup' : reason,
      );
      _doctorCtrl.clear();
      _timeCtrl.clear();
      _reasonCtrl.clear();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _upload(AppApi api, int appointmentId) async {
    setState(() => _error = null);
    final picked = await FilePicker.platform.pickFiles(withData: false);
    if (picked == null || picked.files.isEmpty) return;
    final path = picked.files.single.path;
    if (path == null) return;
    final file = File(path);
    await api.uploadPrescription(appointmentId: appointmentId, file: file, fieldName: 'file');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prescription uploaded')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final auth = context.watch<AuthSession>();
    if (auth.token == null) return const Center(child: Text('Login required'));

    final api = AppApi(client: ApiClient(apiBaseUrl: settings.apiBaseUrl, token: auth.token!));

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Schedule Visit', textScaleFactor: settings.textScale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 12),
            TextField(
              controller: _doctorCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Doctor ID'),
            ),
            TextField(
              controller: _timeCtrl,
              decoration: const InputDecoration(labelText: 'Appointment Time (ISO e.g. 2026-04-16T10:30:00)'),
            ),
            TextField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _busy ? null : () => _add(api),
                child: Text(_busy ? 'Saving...' : 'Book Appointment', textScaleFactor: settings.textScale),
              ),
            ),
            const SizedBox(height: 18),
            Text('Your Appointments', textScaleFactor: settings.textScale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            FutureBuilder<List<dynamic>>(
              future: _load(api),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return const Text('Failed to load appointments');
                }
                final list = snapshot.data!;
                if (list.isEmpty) return const Text('No appointments yet');

                return Column(
                  children: [
                    for (final a in list)
                      _AppointmentCard(
                        appointment: a as Map<String, dynamic>,
                        scale: settings.textScale,
                        onUpload: () => _upload(api, (a['id'] as num).toInt()),
                      )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final double scale;
  final VoidCallback onUpload;

  const _AppointmentCard({required this.appointment, required this.scale, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final id = (appointment['id'] as num).toInt();
    final doctorId = (appointment['doctorId'] as num?)?.toInt() ?? 0;
    final time = appointment['appointmentTime']?.toString() ?? '';
    final reason = appointment['reason'] as String? ?? '';
    final status = appointment['status'] as String? ?? '';

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor ID: $doctorId', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            Text('Time: $time', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Reason: ${reason.isEmpty ? '—' : reason}', textScaleFactor: scale),
            const SizedBox(height: 10),
            Text('Status: $status', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 46,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Prescription'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

