import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_settings.dart';
import '../state/auth_session.dart';
import '../services/api_client.dart';
import '../services/app_api.dart';
import 'login_otp_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _elderIdCtrl = TextEditingController();
  bool _linkBusy = false;
  String? _linkError;

  @override
  void dispose() {
    _elderIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final auth = context.watch<AuthSession>();

    final token = auth.token;
    final api = token == null
        ? null
        : AppApi(client: ApiClient(apiBaseUrl: settings.apiBaseUrl, token: token));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 6),
            Text('Accessibility', textScaleFactor: settings.textScale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 10),
            Card(
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dark mode', textScaleFactor: settings.textScale, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Switch(
                          value: settings.darkMode,
                          onChanged: (v) => settings.setDarkMode(v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Language', textScaleFactor: settings.textScale, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: settings.language,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                        DropdownMenuItem(value: 'kn', child: Text('Kannada')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        settings.setLanguage(v);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Text size', textScaleFactor: settings.textScale, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: settings.textScale,
                      min: 1.0,
                      max: 1.4,
                      onChanged: (v) => settings.setTextScale(v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Backend URL', textScaleFactor: settings.textScale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'API base URL (e.g. http://10.0.2.2:8080)'),
              controller: TextEditingController(text: settings.apiBaseUrl),
              onSubmitted: (v) => settings.setApiBaseUrl(v),
            ),
            const SizedBox(height: 18),
            if (auth.role == 'caregiver') ...[
              Text('Caregiver Linking', textScaleFactor: settings.textScale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 10),
              Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Link an elder to monitor', textScaleFactor: settings.textScale),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _elderIdCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Elder Phone'),
                      ),
                      if (_linkError != null) ...[
                        const SizedBox(height: 8),
                        Text(_linkError!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _linkBusy || api == null
                              ? null
                              : () async {
                                  setState(() {
                                    _linkBusy = true;
                                    _linkError = null;
                                  });
                                  try {
                                    final elderPhone = _elderIdCtrl.text.trim();
                                    await api!.linkCaregiver(elderPhone: elderPhone);
                                    if (!mounted) return;
                                    setState(() => _linkBusy = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Elder linked successfully')),
                                    );
                                  } catch (e) {
                                    setState(() {
                                      _linkBusy = false;
                                      _linkError = e.toString();
                                    });
                                  }
                                },
                          child: Text(_linkBusy ? 'Linking...' : 'Link Elder'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await auth.logout();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginOtpScreen()));
                },
                label: Text('Logout', textScaleFactor: settings.textScale),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

