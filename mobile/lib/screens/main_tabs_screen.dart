import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_settings.dart';
import '../state/auth_session.dart';
import 'dashboard_screen.dart';
import 'caregiver_dashboard_screen.dart';
import 'medicine_reminders_screen.dart';
import 'health_tracker_screen.dart';
import 'emergency_sos_screen.dart';
import 'voice_assistant_screen.dart';
import 'ai_insights_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final auth = context.watch<AuthSession>();

    final home = auth.role == 'caregiver' ? const CaregiverDashboardScreen() : const DashboardScreen();

    final pages = <Widget>[
      home,
      const MedicineRemindersScreen(),
      const HealthTrackerScreen(),
      const EmergencySosScreen(),
      const VoiceAssistantScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.name ?? 'Care Companion', textScaleFactor: settings.textScale),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_accessibility),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          for (int i = 0; i < pages.length; i++)
            Offstage(offstage: _index != i, child: pages[i]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Meds'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'SOS'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Voice'),
        ],
      ),
      floatingActionButton: auth.role == 'caregiver'
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiInsightsScreen()));
              },
              label: const Text('AI'),
              icon: const Icon(Icons.auto_awesome),
            ),
    );
  }
}

