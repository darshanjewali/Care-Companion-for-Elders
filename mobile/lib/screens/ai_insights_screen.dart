import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../services/app_api.dart';
import '../state/app_settings.dart';
import '../state/auth_session.dart';

class AiInsightsScreen extends StatelessWidget {
  const AiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final auth = context.watch<AuthSession>();

    final api = AppApi(client: ApiClient(apiBaseUrl: settings.apiBaseUrl, token: auth.token!));

    return Scaffold(
      appBar: AppBar(title: const Text('AI Health Insights')),
      body: SafeArea(
        child: FutureBuilder(
          future: api.getAiHealthPrediction(),
          builder: (context, snapshot) {
            final scale = settings.textScale;
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Center(child: Text('Failed to load AI insights', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)));
            }
            final data = snapshot.data! as Map<String, dynamic>;
            final risk = data['risk'] as String? ?? 'Low';
            final suggestion = data['suggestion'] as String? ?? '';
            final color = risk.toLowerCase().contains('high') ? Colors.redAccent : risk.toLowerCase().contains('medium') ? Colors.orangeAccent : Colors.green;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Risk Level', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 12),
                Card(
                  elevation: 8,
                  color: color.withOpacity(0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      risk,
                      textScaleFactor: scale,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: color),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Suggestion', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 10),
                Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(suggestion, textScaleFactor: scale, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.local_hospital),
                  label: Text('Consult caregiver/doctor', textScaleFactor: scale),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

