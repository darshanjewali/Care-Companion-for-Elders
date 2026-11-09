import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../services/app_api.dart';
import '../state/app_settings.dart';
import '../state/auth_session.dart';

class MedicineRemindersScreen extends StatefulWidget {
  const MedicineRemindersScreen({super.key});

  @override
  State<MedicineRemindersScreen> createState() => _MedicineRemindersScreenState();
}

class _MedicineRemindersScreenState extends State<MedicineRemindersScreen> {
  String _name = '';
  String _dosage = '';
  String _time = '08:00';
  String _instructions = '';
  bool _busy = false;
  String? _error;

  Future<List<dynamic>> _loadMedicines(AppApi api) => api.getMedicinesToday();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final auth = context.watch<AuthSession>();
    final api = AppApi(client: ApiClient(apiBaseUrl: settings.apiBaseUrl, token: auth.token!));

    if (auth.token == null) {
      return const Center(child: Text('Login required'));
    }

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _loadMedicines(api),
          builder: (context, snapshot) {
            final scale = settings.textScale;
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Failed to load medicines: ${snapshot.error}', textScaleFactor: scale));
            }

            final meds = snapshot.data ?? [];
            return RefreshIndicator(
              onRefresh: () => _loadMedicines(api),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Medicine Reminders', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                  const SizedBox(height: 14),
                  _AddMedicineCard(
                    busy: _busy,
                    error: _error,
                    scale: scale,
                    name: _name,
                    dosage: _dosage,
                    time: _time,
                    instructions: _instructions,
                    onNameChanged: (v) => setState(() => _name = v),
                    onDosageChanged: (v) => setState(() => _dosage = v),
                    onTimeChanged: (v) => setState(() => _time = v),
                    onInstructionsChanged: (v) => setState(() => _instructions = v),
                    onAdd: () async {
                      setState(() {
                        _busy = true;
                        _error = null;
                      });
                      try {
                        await api.createMedicine(
                          name: _name.trim(),
                          dosage: _dosage.trim(),
                          reminderTime: _time.trim(),
                          instructions: _instructions.trim(),
                        );
                        if (!mounted) return;
                        setState(() {
                          _busy = false;
                          _name = '';
                          _dosage = '';
                          _instructions = '';
                        });
                        setState(() {});
                      } catch (e) {
                        setState(() => _error = e.toString());
                      } finally {
                        setState(() => _busy = false);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Today', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 10),
                  if (meds.isEmpty)
                    Text('No reminders for today.', textScaleFactor: scale),
                  for (final m in meds)
                    _MedicineRow(
                      scale: scale,
                      medicine: m as Map<String, dynamic>,
                      onTaken: () async {
                        final id = (m['id'] as num).toInt();
                        setState(() => _busy = true);
                        try {
                          await api.markMedicineTaken(medicineId: id);
                          if (!mounted) return;
                          setState(() => _busy = false);
                          // triggers refresh by rebuilding FutureBuilder via setState
                          setState(() {});
                        } catch (e) {
                          setState(() {
                            _busy = false;
                            _error = e.toString();
                          });
                        }
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AddMedicineCard extends StatelessWidget {
  final bool busy;
  final String? error;
  final double scale;
  final String name;
  final String dosage;
  final String time;
  final String instructions;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDosageChanged;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<String> onInstructionsChanged;
  final Future<void> Function() onAdd;

  const _AddMedicineCard({
    required this.busy,
    required this.error,
    required this.scale,
    required this.name,
    required this.dosage,
    required this.time,
    required this.instructions,
    required this.onNameChanged,
    required this.onDosageChanged,
    required this.onTimeChanged,
    required this.onInstructionsChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Reminder', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Medicine Name'),
              controller: TextEditingController(text: name),
              onChanged: onNameChanged,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Dosage'),
              controller: TextEditingController(text: dosage),
              onChanged: onDosageChanged,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Time (HH:mm)'),
              controller: TextEditingController(text: time),
              onChanged: onTimeChanged,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Instructions (optional)'),
              controller: TextEditingController(text: instructions),
              onChanged: onInstructionsChanged,
            ),
            const SizedBox(height: 10),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: busy ? null : onAdd,
                child: const Text('Add Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicineRow extends StatelessWidget {
  final double scale;
  final Map<String, dynamic> medicine;
  final Future<void> Function() onTaken;

  const _MedicineRow({required this.scale, required this.medicine, required this.onTaken});

  @override
  Widget build(BuildContext context) {
    final status = medicine['status'] as String? ?? 'pending';
    final color = status == 'taken'
        ? Colors.green
        : status == 'missed'
            ? Colors.red
            : Colors.orangeAccent;

    final name = medicine['name'] as String? ?? '';
    final time = medicine['time'] as String? ?? '';
    final id = (medicine['id'] as num).toInt();

    final canTake = status != 'taken';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 6),
            Text('Time: $time', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Status: $status', textScaleFactor: scale, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 10),
            if (canTake)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: onTaken,
                  child: const Text('Mark Taken'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

