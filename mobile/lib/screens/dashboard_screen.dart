import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../services/app_api.dart';
import '../state/app_settings.dart';
import '../state/auth_session.dart';
import 'appointments_screen.dart';
import 'ai_insights_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final auth = context.watch<AuthSession>();
    final token = auth.token;
    if (token == null) {
      return const Center(child: Text('Please login'));
    }

    final api = AppApi(
      client: ApiClient(apiBaseUrl: settings.apiBaseUrl, token: token),
    );

    return FutureBuilder(
      future: api.getDashboard(),
      builder: (context, snapshot) {
        final scale = settings.textScale;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Failed to load dashboard', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: () {},
                      child: const Text('Retry'),
                  )
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final username = data['username'] as String? ?? 'Elder';
        final nextMedicine = data['nextMedicine'] as String? ?? '—';
        final healthStatus = data['healthStatus'] as String? ?? 'Stable';
        final isUnstable = healthStatus.toLowerCase().contains('unstable') || healthStatus.toLowerCase().contains('high');

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Hello, $username',
              textScaleFactor: scale,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            const SizedBox(height: 12),
            _bigCard(
              context: context,
              title: 'Health Status',
              value: healthStatus,
              color: isUnstable ? Colors.redAccent : Colors.green,
              icon: Icons.favorite,
            ),
            const SizedBox(height: 12),
            _bigCard(
              context: context,
              title: 'Next Medicine',
              value: nextMedicine,
              color: Colors.blueAccent,
              icon: Icons.medication,
            ),
            const SizedBox(height: 16),
            Text('Quick Actions', textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _actionButton(context, scale, Icons.medication, 'Medicines', () {}),
                _actionButton(context, scale, Icons.monitor_heart, 'Health', () {}),
                _actionButton(
                  context,
                  scale,
                  Icons.auto_awesome,
                  'AI Insights',
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiInsightsScreen())),
                ),
                _actionButton(
                  context,
                  scale,
                  Icons.calendar_month,
                  'Appointments',
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AppointmentsScreen())),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _bigCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final scale = context.watch<AppSettings>().textScale;
    return Card(
      elevation: 6,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 6),
                  Text(value, textScaleFactor: scale, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: color)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, double scale, IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(140, 72),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: const BorderSide(color: Colors.black12),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 28),
      label: Text(label, textScaleFactor: scale, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

