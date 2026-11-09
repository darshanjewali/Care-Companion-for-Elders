import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../services/app_api.dart';
import '../state/app_settings.dart';
import '../state/auth_session.dart';

class CaregiverDashboardScreen extends StatelessWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final auth = context.watch<AuthSession>();
    if (auth.token == null) return const Center(child: Text('Login required'));

    final api = AppApi(client: ApiClient(apiBaseUrl: settings.apiBaseUrl, token: auth.token!));

    return FutureBuilder(
      future: api.getCaregiverPatientData(),
      builder: (context, snapshot) {
        final scale = settings.textScale;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 12),
                Text('Failed to load patient data', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        final list = snapshot.data! as List<dynamic>;
        if (list.isEmpty) {
          return Center(
            child: Text('No linked elders yet.\nOpen Profile to link.', textAlign: TextAlign.center, textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final item = list[i] as Map<String, dynamic>;
            final elderName = item['elderName'] as String? ?? 'Elder';
            final latest = item['latest'] as Map<String, dynamic>? ?? {};
            final bp = latest['bp'] as String? ?? 'N/A';
            final sugar = latest['sugar'] as String? ?? 'N/A';
            final hr = latest['heartRate'] as int? ?? 0;
            final missed = item['missedMedsCount'] as int? ?? 0;
            final sos = item['recentSosCount'] as int? ?? 0;

            final riskColor = missed > 0 || sos > 0 ? Colors.redAccent : Colors.green;

            return Card(
              elevation: 6,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(elderName, textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                    const SizedBox(height: 10),
                    _miniRow('BP', bp, scale),
                    _miniRow('Sugar', sugar, scale),
                    _miniRow('Heart Rate', '$hr', scale),
                    const SizedBox(height: 10),
                    _statusChip('Missed meds: $missed', riskColor),
                    const SizedBox(height: 8),
                    _statusChip('Recent SOS: $sos', riskColor),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _miniRow(String label, String value, double scale) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    );
  }
}

