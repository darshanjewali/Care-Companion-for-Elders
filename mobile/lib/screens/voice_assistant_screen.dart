import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_client.dart';
import '../services/app_api.dart';
import '../state/app_settings.dart';
import '../state/auth_session.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;
  bool _listening = false;
  String _transcript = '';
  String? _error;
  String? _intent;
  String? _message;

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onStatus: (status) {},
      onError: (error) {
        setState(() => _error = error.toString());
      },
    );
    setState(() => _available = ok);
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _startListening(String lang) async {
    setState(() {
      _error = null;
      _intent = null;
      _message = null;
      _transcript = '';
    });
    await _speech.listen(
      localeId: lang == 'hi' ? 'hi-IN' : lang == 'kn' ? 'kn-IN' : 'en-US',
      onResult: (res) {
        setState(() {
          _transcript = res.recognizedWords;
        });
      },
    );
    setState(() => _listening = true);
  }

  Future<void> _stopListening(AppApi api) async {
    await _speech.stop();
    setState(() => _listening = false);
    final command = _transcript.trim();
    if (command.isEmpty) {
      setState(() => _error = 'No speech detected.');
      return;
    }

    try {
      final resp = await api.voiceCommand(command: command, lang: 'en');
      setState(() {
        _intent = resp['intent'] as String?;
        _message = resp['message'] as String?;
      });
    } catch (e) {
      setState(() => _error = e.toString());
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Voice Assistant', textScaleFactor: settings.textScale, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transcript:', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        _transcript.isEmpty ? 'Say something like: “Remind medicines” or “SOS”.' : _transcript,
                        style: TextStyle(fontSize: 20 * settings.textScale),
                      ),
                      const SizedBox(height: 12),
                      if (_intent != null)
                        Text('Intent: $_intent', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (_message != null)
                        Text('Response: $_message', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                      onPressed: !_available ? null : () async {
                        if (_listening) {
                          await _stopListening(api);
                        } else {
                          await _startListening(settings.language);
                        }
                      },
                      child: Text(
                        !_available
                            ? 'Voice not available'
                            : _listening
                                ? 'Stop Listening'
                                : 'Hold to Speak',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

